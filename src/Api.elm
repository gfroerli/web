module Api exposing (getHeaders, Sensor, JsSensor, sensorDecoder, toJsSensor)

import Date exposing (Date)
import Http
import Json.Decode as Decode
import Json.Decode.Extra as DecodeExtra
import Json.Decode.Pipeline as Pipeline
import Map


-- AUTHENTICATION


getHeaders : String -> List Http.Header
getHeaders apiToken =
    [ Http.header "Authorization" ("Bearer " ++ apiToken) ]



-- MODELS


type alias Sensor =
    { id : Int
    , deviceName : String
    , caption : Maybe String
    , latitude : Float
    , longitude : Float
    , sponsorId : Maybe Int
    , createdAt : Date
    , updatedAt : Date
    }


type alias JsSensor =
    { id : Int
    , deviceName : String
    , caption : Maybe String
    , pos : Map.Pos
    }



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
