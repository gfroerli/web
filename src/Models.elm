module Models exposing (..)

import Date exposing (Date)
import Map
import Time


type alias Model =
    { route : Route
    , map : Map.Model
    , sensors : List Sensor
    , selectedSensor : Maybe Sensor
    , apiToken : String
    , now : Maybe Time.Time
    }


type Route
    = MapRoute
    | AboutRoute
    | NotFoundRoute


type alias Sensor =
    { id : Int
    , deviceName : String
    , caption : Maybe String
    , latitude : Float
    , longitude : Float
    , sponsorId : Maybe Int
    , createdAt : Date
    , updatedAt : Date
    , lastMeasurement : Maybe Measurement
    , historicMeasurements : Maybe (List Measurement)
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
    , createdAt : Date
    }


type alias JsMeasurement =
    { temperature : Float
    }
