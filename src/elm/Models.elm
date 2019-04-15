module Models exposing (JsMeasurement, JsSensor, Measurement, Model, Sensor, Sponsor)

import Browser.Navigation as Nav
import Dict exposing (Dict)
import Map
import Routing exposing (Route)
import Time


type alias Model =
    { key : Nav.Key
    , route : Route
    , map : Map.Model
    , sensors : List Sensor
    , selectedSensor : Maybe Sensor
    , sponsors : Dict Int Sponsor
    , apiToken : String
    , now : Maybe Time.Posix
    }


type alias Sensor =
    { id : Int
    , deviceName : String
    , caption : Maybe String
    , latitude : Float
    , longitude : Float
    , sponsorId : Maybe Int
    , createdAt : Time.Posix
    , updatedAt : Time.Posix
    , lastMeasurement : Maybe Measurement
    , historicMeasurements : Maybe (List Measurement)
    }


type alias Sponsor =
    { name : String
    , description : String
    , active : Bool
    }


type alias JsSensor =
    { id : Int
    , deviceName : String
    , caption : Maybe String
    , pos : Map.Pos
    , lastMeasurement : Maybe JsMeasurement
    }


type alias Measurement =
    { id : Int
    , sensorId : Maybe Int
    , temperature : Float
    , createdAt : Time.Posix
    }


type alias JsMeasurement =
    { temperature : Float
    }
