module Main exposing (..)

import Api
import Date exposing (toTime)
import Html.Styled exposing (toUnstyled)
import List.Extra exposing (find)
import Map
import MapPort
import Maybe.Extra
import Messages exposing (..)
import Models exposing (Model, Route(..))
import Navigation
import Navigation exposing (Location)
import Routing exposing (parseLocation)
import Task
import Time
import Views exposing (view)


main : Program Flags Model Msg
main =
    Navigation.programWithFlags LocationChange
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }


type alias Flags =
    { apiToken : String
    }



-- MODEL


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        map =
            Map.init

        currentRoute =
            parseLocation location
    in
        ( { route = currentRoute
          , map = map
          , sensors = []
          , selectedSensor = Nothing
          , apiToken = flags.apiToken
          , time = Nothing
          }
        , Cmd.batch
            [ MapPort.initializeMap map
            , Task.perform TimeUpdate Time.now
            ]
        )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate newTime ->
            ( { model | time = Just newTime }, Cmd.none )

        LocationChange location ->
            let
                -- Determine the new route by parsing the location
                newRoute =
                    parseLocation location

                -- Determine any side effects (e.g. map init) caused by the location change
                cmd =
                    case newRoute of
                        MapRoute ->
                            -- Re-initialize map
                            MapPort.initializeMap model.map

                        AboutRoute ->
                            Cmd.none

                        NotFoundRoute ->
                            Cmd.none
            in
                ( { model | route = newRoute }, cmd )

        MapInitialized _ ->
            ( model, Api.loadSensors model.apiToken )

        SensorsLoaded (Ok sensors) ->
            ( { model | selectedSensor = Nothing, sensors = sensors }
            , List.map Api.toJsSensor sensors
                |> MapPort.sensorsLoaded
            )

        SensorsLoaded (Err error) ->
            let
                _ =
                    -- TODO
                    Debug.log "Error while fetching data" error
            in
                ( model, Cmd.none )

        MeasurementsLoaded ( sensorId, Ok measurements ) ->
            let
                -- Get selected sensor if the sensor id in the received
                -- measurements matches its id.
                sensor =
                    Maybe.Extra.filter (\sensor -> sensor.id == sensorId) model.selectedSensor

                updatedModel =
                    case sensor of
                        Just sensor ->
                            let
                                sortedMeasurements =
                                    List.sortBy (.createdAt >> toTime) measurements

                                updatedSensor =
                                    { sensor | historicMeasurements = Just sortedMeasurements }
                            in
                                { model | selectedSensor = Just updatedSensor }

                        Nothing ->
                            model
            in
                ( updatedModel, Cmd.none )

        MeasurementsLoaded ( sensorId, Err error ) ->
            let
                _ =
                    -- TODO
                    Debug.log ("Error while fetching measurements for sensor " ++ (toString sensorId)) error
            in
                ( model, Cmd.none )

        MapDragged pos ->
            let
                oldMap =
                    model.map

                newMap =
                    { oldMap
                        | lat = pos.lat
                        , lng = pos.lng
                        , zoom = pos.zoom
                    }
            in
                ( { model | map = newMap }, Cmd.none )

        SensorClicked (Just jsSensor) ->
            let
                selectedSensor =
                    find (\sensor -> sensor.id == jsSensor.id)
                        model.sensors

                cmd =
                    case ( model.time, selectedSensor ) of
                        ( Just now, Just sensor ) ->
                            Api.loadSensorMeasurements
                                model.apiToken
                                now
                                sensor.id
                                (3600 * 24 * 3)

                        _ ->
                            Cmd.none
            in
                ( { model | selectedSensor = selectedSensor }, cmd )

        SensorClicked Nothing ->
            ( { model | selectedSensor = Nothing }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ MapPort.mapInitialized MapInitialized
        , MapPort.mapMoved MapDragged
        , MapPort.sensorClicked SensorClicked
        , Time.every (30 * Time.second) TimeUpdate
        ]
