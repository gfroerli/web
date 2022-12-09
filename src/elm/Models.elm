module Models exposing
    ( Alert
    , JsSensor
    , Measurement
    , Model
    , Sensor
    , Severity(..)
    , Sponsor
    , addErrorAlert
    )

import Browser.Navigation as Nav
import Dict exposing (Dict)
import Map
import Routing exposing (Route)
import Time


type Severity
    = Error


type alias Alert =
    { severity : Severity
    , message : String
    }


{-| Add an error alert message to the model.
-}
addErrorAlert : Model -> String -> Model
addErrorAlert model msg =
    let
        alert =
            { severity = Error
            , message = msg
            }
    in
    { model | alerts = alert :: model.alerts }


type alias Model =
    { key : Nav.Key
    , route : Route
    , map : Map.Model
    , sensors : List Sensor
    , selectedSensor : Maybe Sensor
    , sponsors : Dict Int Sponsor
    , apiToken : String
    , now : Maybe Time.Posix
    , alerts : List Alert
    }


type alias Sensor =
    { id : Int
    , deviceName : String
    , caption : Maybe String
    , latitude : Float
    , longitude : Float
    , createdAt : Time.Posix
    , sponsorId : Maybe Int
    , latestTemperature : Maybe Float
    , latestMeasurementAt : Maybe Time.Posix
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
    , latestTemperature : Maybe Float
    }


type alias Measurement =
    { id : Int
    , sensorId : Maybe Int
    , temperature : Float
    , createdAt : Time.Posix
    }
