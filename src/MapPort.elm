port module MapPort exposing (..)

import Map


-- Outgoing Port


port initializeMap : Map.JsObject -> Cmd msg


port moveMap : Map.JsObject -> Cmd msg



-- Incoming Port


port mapMoved : (Map.JsObject -> msg) -> Sub msg
