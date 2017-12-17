module Main exposing (..)

import Api
import Html
import Html.Styled exposing (toUnstyled)
import List.Extra exposing (find)
import Map
import MapPort
import Messages exposing (..)
import Models exposing (Model)
import Views exposing (view)


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }


type alias Flags =
    { apiToken : String
    }



-- MODEL


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        map =
            Map.init
    in
        ( Model map [] Nothing flags.apiToken
        , MapPort.initializeMap map
        )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MapInitialized _ ->
            ( model, Api.loadSensors model.apiToken )

        DataLoaded result ->
            case result of
                Ok sensors ->
                    ( { model | selectedSensor = Nothing, sensors = sensors }
                    , List.map Api.toJsSensor sensors
                        |> MapPort.sensorsLoaded
                    )

                Err error ->
                    let
                        _ =
                            -- TODO
                            Debug.log "Error while fetching data" error
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
            in
                ( { model | selectedSensor = selectedSensor }, Cmd.none )

        SensorClicked Nothing ->
            ( { model | selectedSensor = Nothing }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ MapPort.mapInitialized MapInitialized
        , MapPort.mapMoved MapDragged
        , MapPort.sensorClicked SensorClicked
        ]
