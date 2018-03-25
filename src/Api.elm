module Api exposing (..)

import Date
import Date.Format
import Http
import Json.Decode as Decode
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline as Pipeline
import Map
import Messages exposing (..)
import Models exposing (Sensor, JsSensor, Measurement, JsMeasurement)
import Time


-- AUTHENTICATION


getHeaders : String -> List Http.Header
getHeaders apiToken =
    [ Http.header "Authorization" ("Bearer " ++ apiToken) ]



-- DECODERS


sensorDecoder : Decode.Decoder Sensor
sensorDecoder =
    Pipeline.decode Sensor
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "device_name" Decode.string
        |> Pipeline.required "caption" (Decode.nullable Decode.string)
        |> Pipeline.required "latitude" Decode.float
        |> Pipeline.required "longitude" Decode.float
        |> Pipeline.required "sponsor_id" (Decode.nullable Decode.int)
        |> Pipeline.required "created_at" DecodeExtra.date
        |> Pipeline.required "updated_at" DecodeExtra.date
        |> Pipeline.optional "last_measurement" (Decode.nullable measurementDecoder) Nothing
        |> Pipeline.hardcoded Nothing


measurementDecoder : Decode.Decoder Measurement
measurementDecoder =
    Pipeline.decode Measurement
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "sensor_id" (Decode.nullable Decode.int)
        |> Pipeline.required "temperature" Decode.string
        |> Pipeline.required "created_at" DecodeExtra.date



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


loadSensors : String -> Cmd Msg
loadSensors apiToken =
    let
        url =
            "https://watertemp-api.coredump.ch/api/sensors"

        request =
            Http.request
                { method = "GET"
                , headers = getHeaders apiToken
                , url = url
                , body = Http.emptyBody
                , expect = Http.expectJson (Decode.list sensorDecoder)
                , timeout = Just (30 * Time.second)
                , withCredentials = False
                }
    in
        Http.send SensorsLoaded request


loadSensorMeasurements : String -> Time.Time -> Int -> Int -> Cmd Msg
loadSensorMeasurements apiToken now sensorId secondsAgo =
    let
        createdAfter =
            Date.fromTime <| now - ((toFloat secondsAgo) * Time.second)

        url =
            "https://watertemp-api.coredump.ch/api/measurements?sensorId="
                ++ (toString sensorId)
                ++ "&createdAfter="
                ++ (Date.Format.formatISO8601 createdAfter)

        request =
            Http.request
                { method = "GET"
                , headers = getHeaders apiToken
                , url = url
                , body = Http.emptyBody
                , expect = Http.expectJson (Decode.list measurementDecoder)
                , timeout = Just (30 * Time.second)
                , withCredentials = False
                }
    in
        Http.send (\res -> (MeasurementsLoaded ( sensorId, res ))) request
