module Models exposing (..)

import Map
import Api


type alias Model =
    { map : Map.Model
    , sensors : List Api.Sensor
    , selectedSensor : Maybe Api.Sensor
    , apiToken : String
    }
