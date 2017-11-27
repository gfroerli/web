port module MapPort exposing (..)

import Api
import Map


-- Outgoing Port


port initializeMap : Map.Model -> Cmd msg


port moveMap : Map.Model -> Cmd msg


port sensorsLoaded : List Api.JsSensor -> Cmd msg



-- Incoming Port


port mapMoved : (Map.Model -> msg) -> Sub msg
