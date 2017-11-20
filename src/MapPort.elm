port module MapPort exposing (..)

import Map


-- Outgoing Port


port initializeMap : Map.Model -> Cmd msg


port moveMap : Map.Model -> Cmd msg



-- Incoming Port


port mapMoved : (Map.Model -> msg) -> Sub msg
