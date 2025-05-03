module Models exposing
    ( Alert
    , DelayedSensorDetails(..)
    , DelayedSponsor(..)
    , JsSensor
    , Measurement
    , Model
    , Sensor
    , SensorDetails
    , Severity(..)
    , Sponsor
    , addErrorAlert
    , findJsSensorWithId
    )

import Browser.Navigation as Nav
import List.Extra
import Map
import Routing exposing (Route)
import Time


type Severity
    = Error


type alias Alert =
    { severity : Severity
    , message : String
    }


type DelayedSensorDetails
    = SensorLoaded SensorDetails
    | SensorLoading
    | SensorMissing


type DelayedSponsor
    = SponsorLoaded Sponsor
    | SponsorLoading
    | SponsorMissing


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
    , initialSensorId : Maybe Int
    , selectedSensor : DelayedSensorDetails
    , selectedSponsor : DelayedSponsor
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


type alias SensorDetails =
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
    , averageTemperature : Maybe Float
    , minimumTemperature : Maybe Float
    , maximumTemperature : Maybe Float
    }


type alias Sponsor =
    { id : Int
    , name : String
    , description : String
    , logo_url : Maybe String
    }


type alias JsSensor =
    { id : Int
    , deviceName : String
    , caption : Maybe String
    , pos : Map.Pos
    , latestTemperature : Maybe Float
    }


{-| Given an (optional) sensor ID, find the corresponding sensor in the list of JS sensors.
-}
findJsSensorWithId : Maybe Int -> List JsSensor -> Maybe JsSensor
findJsSensorWithId maybeId sensors =
    Maybe.andThen (\id -> List.Extra.find (\sensor -> sensor.id == id) sensors) maybeId


type alias Measurement =
    { id : Int
    , sensorId : Maybe Int
    , temperature : Float
    , createdAt : Time.Posix
    }
