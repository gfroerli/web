module Api exposing
    ( apiTimeout
    , errorToString
    , getHeaders
    , getUrl
    , loadSensorMeasurements
    , loadSensors
    , loadSponsor
    , measurementDecoder
    , sensorDecoder
    , sponsorDecoder
    , toJsMeasurement
    , toJsSensor
    )

import Http exposing (Error(..))
import Iso8601
import Json.Decode as Decode
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline as Pipeline
import Map
import Messages exposing (..)
import Models exposing (JsMeasurement, JsSensor, Measurement, Sensor, Sponsor)
import Time exposing (Posix, millisToPosix, posixToMillis)



-- AUTHENTICATION


getHeaders : String -> List Http.Header
getHeaders apiToken =
    [ Http.header "Authorization" ("Bearer " ++ apiToken) ]



-- DECODERS


sensorDecoder : Decode.Decoder Sensor
sensorDecoder =
    Decode.succeed Sensor
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "device_name" Decode.string
        |> Pipeline.required "caption" (Decode.nullable Decode.string)
        |> Pipeline.required "latitude" Decode.float
        |> Pipeline.required "longitude" Decode.float
        |> Pipeline.required "sponsor_id" (Decode.nullable Decode.int)
        |> Pipeline.required "created_at" DecodeExtra.datetime
        |> Pipeline.required "updated_at" DecodeExtra.datetime
        |> Pipeline.optional "last_measurement" (Decode.nullable measurementDecoder) Nothing
        |> Pipeline.hardcoded Nothing


sponsorDecoder : Decode.Decoder Sponsor
sponsorDecoder =
    Decode.succeed Sponsor
        |> Pipeline.required "name" Decode.string
        |> Pipeline.optional "description" Decode.string ""
        |> Pipeline.optional "active" Decode.bool False


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
        (Maybe.map toJsMeasurement sensor.lastMeasurement)


toJsMeasurement : Measurement -> JsMeasurement
toJsMeasurement measurement =
    JsMeasurement
        measurement.temperature



-- API REQUESTS


apiTimeout : Float
apiTimeout =
    30 * 1000


getUrl : String -> String
getUrl path =
    "https://watertemp-api.coredump.ch/api/" ++ path


loadSensors : String -> Cmd Msg
loadSensors apiToken =
    let
        url =
            getUrl "sensors"
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
loadSponsor apiToken sponsorId =
    let
        url =
            getUrl "sponsors/" ++ String.fromInt sponsorId

        handler =
            \res -> SponsorLoaded ( sponsorId, res )
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
