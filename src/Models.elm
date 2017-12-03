module Models exposing (..)

import Date exposing (Date)
import Map


type alias Model =
    { map : Map.Model
    , sensors : List Sensor
    , selectedSensor : Maybe Sensor
    , apiToken : String
    }


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
