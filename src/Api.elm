module Api exposing (getHeaders, Sensor, sensorDecoder)

import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline


-- AUTHENTICATION


getHeaders : String -> List Http.Header
getHeaders apiToken =
    [ Http.header "Authorization" ("Bearer " ++ apiToken) ]



-- DECODERS


type alias Sensor =
    { id : Int
    , deviceName : String
    , caption : Maybe String
    }


sensorDecoder : Decode.Decoder Sensor
sensorDecoder =
    Pipeline.decode Sensor
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "device_name" Decode.string
        |> Pipeline.required "caption" (Decode.nullable Decode.string)
