module Api exposing (getHeaders, sensorDecoder, toJsSensor, loadSensors)

import Http
import Json.Decode as Decode
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline as Pipeline
import Map
import Messages exposing (..)
import Models exposing (Sensor, JsSensor)
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
        Http.send DataLoaded request
