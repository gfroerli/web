port module MapPort exposing
    ( initializeMap
    , mapInitializationFailed
    , mapInitialized
    , mapMoved
    , sensorClicked
    , sensorsLoaded
    )

import Map
import Models



-- Outgoing Port


port initializeMap : Map.Model -> Cmd msg


{-| Pass sensors to JS.

First parameter: List of all sensors.
Second parameter: Optional initially selected sensor.

-}
port sensorsLoaded : ( List Models.JsSensor, Maybe Models.JsSensor ) -> Cmd msg



-- Incoming Port


port mapInitialized : (() -> msg) -> Sub msg


port mapInitializationFailed : (String -> msg) -> Sub msg


port mapMoved : (Map.Model -> msg) -> Sub msg


port sensorClicked : (Maybe Models.JsSensor -> msg) -> Sub msg
