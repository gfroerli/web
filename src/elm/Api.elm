module Api exposing
    ( apiTimeout
    , errorToString
    , getHeaders
    , getUrl
    , loadSensorDetails
    , loadSensorMeasurements
    , loadSensors
    , loadSponsor
    , measurementDecoder
    , sensorDecoder
    , sponsorDecoder
    , toJsSensor
    )

import Http exposing (Error(..))
import Iso8601
import Json.Decode as Decode
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline as Pipeline
import Map
import Messages exposing (..)
import Models exposing (JsSensor, Measurement, Sensor, SensorDetails, Sponsor)
import Time exposing (Posix, millisToPosix, posixToMillis)



-- AUTHENTICATION


getHeaders : String -> List Http.Header
getHeaders apiToken =
    [ Http.header "Authorization" ("Bearer " ++ apiToken)
    , Http.header "Cache-Control" "no-store"
    ]



-- DECODERS


{-| Decode a posix time (in seconds).
-}
posixSecondsTimeDecoder : Decode.Decoder Time.Posix
posixSecondsTimeDecoder =
    Decode.map (\seconds -> Time.millisToPosix (seconds * 1000)) Decode.int


sensorDecoder : Decode.Decoder Sensor
sensorDecoder =
    Decode.succeed Sensor
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "device_name" Decode.string
        |> Pipeline.required "caption" (Decode.nullable Decode.string)
        |> Pipeline.required "latitude" Decode.float
        |> Pipeline.required "longitude" Decode.float
        |> Pipeline.required "created_at" posixSecondsTimeDecoder
        |> Pipeline.required "sponsor_id" (Decode.nullable Decode.int)
        |> Pipeline.required "latest_temperature" (Decode.nullable Decode.float)
        |> Pipeline.required "latest_measurement_at" (Decode.nullable posixSecondsTimeDecoder)
        |> Pipeline.hardcoded Nothing


sensorDetailsDecoder : Decode.Decoder SensorDetails
sensorDetailsDecoder =
    Decode.succeed SensorDetails
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "device_name" Decode.string
        |> Pipeline.required "caption" (Decode.nullable Decode.string)
        |> Pipeline.required "latitude" Decode.float
        |> Pipeline.required "longitude" Decode.float
        |> Pipeline.required "created_at" posixSecondsTimeDecoder
        |> Pipeline.required "sponsor_id" (Decode.nullable Decode.int)
        |> Pipeline.optional "latest_temperature" (Decode.nullable Decode.float) Nothing
        |> Pipeline.optional "latest_measurement_at" (Decode.nullable posixSecondsTimeDecoder) Nothing
        |> Pipeline.hardcoded Nothing
        |> Pipeline.required "average_temperature" (Decode.nullable Decode.float)
        |> Pipeline.required "minimum_temperature" (Decode.nullable Decode.float)
        |> Pipeline.required "maximum_temperature" (Decode.nullable Decode.float)


sponsorDecoder : Decode.Decoder Sponsor
sponsorDecoder =
    Decode.succeed Sponsor
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "name" Decode.string
        |> Pipeline.optional "description" Decode.string ""
        |> Pipeline.required "logo_url" (Decode.nullable Decode.string)


measurementDecoder : Decode.Decoder Measurement
measurementDecoder =
    Decode.succeed Measurement
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "sensor_id" (Decode.nullable Decode.int)
        |> Pipeline.required "temperature" Decode.float
        |> Pipeline.required "created_at" DecodeExtra.datetime



-- HELPERS


toJsSensor : Sensor -> JsSensor
toJsSensor sensor =
    JsSensor
        sensor.id
        sensor.deviceName
        sensor.caption
        (Map.Pos
            sensor.latitude
            sensor.longitude
        )
        sensor.latestTemperature



-- API REQUESTS


apiTimeout : Float
apiTimeout =
    30 * 1000


getUrl : String -> String
getUrl path =
    "https://watertemp-api.coredump.ch/api/" ++ path


getAppUrl : String -> String
getAppUrl path =
    "https://watertemp-api.coredump.ch/api/mobile_app/" ++ path


loadSensors : String -> Cmd Msg
loadSensors apiToken =
    let
        url =
            getAppUrl "sensors"
    in
    Http.request
        { method = "GET"
        , headers = getHeaders apiToken
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson SensorsLoaded (Decode.list sensorDecoder)
        , timeout = Just apiTimeout
        , tracker = Nothing
        }


loadSensorDetails : String -> Int -> Cmd Msg
loadSensorDetails apiToken sensorId =
    let
        url =
            getAppUrl "sensors/" ++ String.fromInt sensorId
    in
    Http.request
        { method = "GET"
        , headers = getHeaders apiToken
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson SensorDetailsLoaded sensorDetailsDecoder
        , timeout = Just apiTimeout
        , tracker = Nothing
        }


loadSensorMeasurements : String -> Posix -> Int -> Int -> Cmd Msg
loadSensorMeasurements apiToken now sensorId secondsAgo =
    let
        createdAfter =
            millisToPosix <| posixToMillis now - secondsAgo * 1000

        url =
            getUrl "measurements?sensor_id="
                ++ String.fromInt sensorId
                ++ "&created_after="
                ++ Iso8601.fromTime createdAfter

        handler =
            \res -> MeasurementsLoaded ( sensorId, res )
    in
    Http.request
        { method = "GET"
        , headers = getHeaders apiToken
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson handler (Decode.list measurementDecoder)
        , timeout = Just apiTimeout
        , tracker = Nothing
        }


loadSponsor : String -> Int -> Cmd Msg
loadSponsor apiToken sensorId =
    let
        url =
            getUrl "mobile_app/sensors/" ++ String.fromInt sensorId ++ "/sponsor"

        handler =
            \res -> SponsorLoaded res
    in
    Http.request
        { method = "GET"
        , headers = getHeaders apiToken
        , url = url
        , body = Http.emptyBody
        , expect = Http.expectJson handler sponsorDecoder
        , timeout = Just apiTimeout
        , tracker = Nothing
        }



-- ERROR HANDLING


errorToString : Http.Error -> String
errorToString error =
    case error of
        BadUrl _ ->
            "BadUrl"

        Timeout ->
            "Server antwortet nicht"

        NetworkError ->
            "Netzwerk-Fehler"

        BadStatus code ->
            "HTTP " ++ String.fromInt code

        BadBody _ ->
            "Fehlerhafte Server-Antwort"
