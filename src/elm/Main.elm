module Main exposing (Flags, init, main, subscriptions, update)

import Api
import Browser
import Browser.Navigation as Nav
import Map
import MapPort
import Messages exposing (..)
import Models exposing (Model)
import Routing exposing (routeNeedsMap, toRoute)
import Task
import Time exposing (posixToMillis)
import Url
import Views exposing (view)


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = LinkClicked
        , onUrlChange = UrlChanged
        }


type alias Flags =
    { apiToken : String
    }



-- MODEL


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        map =
            Map.init

        currentRoute =
            toRoute url

        currentRouteNeedsMap =
            routeNeedsMap currentRoute
    in
    ( { key = key
      , route = currentRoute
      , map = map
      , sensors = []
      , selectedSensor = Models.SensorMissing
      , selectedSponsor = Models.SponsorMissing
      , apiToken = flags.apiToken
      , now = Nothing
      , alerts = []
      }
    , Cmd.batch
        -- Note: Initialize map only if needed. The TimeUpdate task on the other
        -- hand is always needed.
        (if currentRouteNeedsMap then
            [ MapPort.initializeMap map
            , Task.perform TimeUpdate Time.now
            ]

         else
            [ Task.perform TimeUpdate Time.now ]
        )
    )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TimeUpdate newTime ->
            ( { model | now = Just newTime }, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.External href ->
                    ( model, Nav.load href )

                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

        UrlChanged url ->
            let
                -- Determine the new route by parsing the location
                newRoute =
                    toRoute url

                -- Determine any side effects (e.g. map init) caused by the location change
                cmd =
                    case newRoute of
                        Routing.MapRoute ->
                            MapPort.initializeMap model.map

                        Routing.AboutRoute ->
                            Cmd.none

                        Routing.PrivacyPolicyRoute ->
                            Cmd.none

                        Routing.NotFoundRoute ->
                            Cmd.none
            in
            ( { model | route = newRoute }, cmd )

        MapInitialized _ ->
            ( model, Api.loadSensors model.apiToken )

        MapInitializationFailed alertMsg ->
            ( Models.addErrorAlert model alertMsg, Cmd.none )

        SensorsLoaded (Ok sensors) ->
            -- Filter sensors, exclude sensors that haven't sent any measurements in more than 7 days
            let
                maxMeasurementAgeMillis =
                    7 * 24 * 60 * 60 * 1000

                filteredSensors =
                    List.filter
                        (\sensor ->
                            case ( model.now, sensor.latestMeasurementAt ) of
                                ( Just now, Just latestMeasurementAt ) ->
                                    (Time.posixToMillis now - Time.posixToMillis latestMeasurementAt) < maxMeasurementAgeMillis

                                _ ->
                                    False
                        )
                        sensors
            in
            ( { model | selectedSensor = Models.SensorMissing, sensors = filteredSensors }
            , List.map Api.toJsSensor filteredSensors
                |> MapPort.sensorsLoaded
            )

        SensorsLoaded (Err error) ->
            let
                alertMsg =
                    "Sensoren konnten nicht geladen werden: " ++ Api.errorToString error
            in
            ( Models.addErrorAlert model alertMsg, Cmd.none )

        SensorDetailsLoaded (Ok sensorDetails) ->
            let
                -- Trigger loading of sensor measurements
                cmdMeasurements =
                    case model.now of
                        Just now ->
                            Api.loadSensorMeasurements
                                model.apiToken
                                now
                                sensorDetails.id
                                (3600 * 24 * 3)

                        _ ->
                            Cmd.none
            in
            ( { model | selectedSensor = Models.SensorLoaded sensorDetails }, cmdMeasurements )

        SensorDetailsLoaded (Err error) ->
            let
                alertMsg =
                    "Sensoren konnten nicht geladen werden: " ++ Api.errorToString error
            in
            ( Models.addErrorAlert model alertMsg, Cmd.none )

        SponsorLoaded (Ok sponsor) ->
            ( { model | selectedSponsor = Models.SponsorLoaded sponsor }, Cmd.none )

        SponsorLoaded (Err error) ->
            let
                alertMsg =
                    "Sponsor-Daten für Sensor  konnten nicht geladen werden: "
                        ++ Api.errorToString error
            in
            ( Models.addErrorAlert model alertMsg, Cmd.none )

        MeasurementsLoaded ( sensorId, Ok measurements ) ->
            let
                -- Get selected sensor if the sensor id in the received
                -- measurements matches its id.
                sensor =
                    case model.selectedSensor of
                        Models.SensorMissing ->
                            Nothing

                        Models.SensorLoading ->
                            Nothing

                        Models.SensorLoaded sensorDetails ->
                            if sensorDetails.id == sensorId then
                                Just sensorDetails

                            else
                                Nothing

                -- Update the model if the measurements belong to the current sensor
                updatedModel =
                    case sensor of
                        Just s ->
                            let
                                sortedMeasurements =
                                    List.sortBy (.createdAt >> posixToMillis) measurements

                                updatedSensor =
                                    { s | historicMeasurements = Just sortedMeasurements }
                            in
                            { model | selectedSensor = Models.SensorLoaded updatedSensor }

                        Nothing ->
                            model
            in
            ( updatedModel, Cmd.none )

        MeasurementsLoaded ( sensorId, Err error ) ->
            let
                alertMsg =
                    "Messungen für Sensor "
                        ++ String.fromInt sensorId
                        ++ " konnten nicht geladen werden: "
                        ++ Api.errorToString error
            in
            ( Models.addErrorAlert model alertMsg, Cmd.none )

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
                -- Trigger loading of sensor details
                cmdSensorDetails =
                    Api.loadSensorDetails model.apiToken jsSensor.id

                -- Trigger loading of sponsor information
                cmdSponsor =
                    Api.loadSponsor model.apiToken jsSensor.id

                cmd =
                    Cmd.batch [ cmdSensorDetails, cmdSponsor ]
            in
            ( { model | selectedSensor = Models.SensorLoading }, cmd )

        SensorClicked Nothing ->
            ( { model | selectedSensor = Models.SensorMissing }, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ MapPort.mapInitialized MapInitialized
        , MapPort.mapInitializationFailed MapInitializationFailed
        , MapPort.mapMoved MapDragged
        , MapPort.sensorClicked SensorClicked
        , Time.every (10 * 1000) TimeUpdate -- Update current time every 10 seconds
        ]
