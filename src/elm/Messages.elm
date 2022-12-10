module Messages exposing (Msg(..))

import Browser
import Http
import Map
import Models
import Time
import Url


type Msg
    = MapInitialized ()
    | MapInitializationFailed String
    | MapDragged Map.Model
    | SensorsLoaded (Result Http.Error (List Models.Sensor))
    | SensorClicked (Maybe Models.JsSensor)
    | SensorDetailsLoaded (Result Http.Error Models.SensorDetails)
    | MeasurementsLoaded ( Int, Result Http.Error (List Models.Measurement) )
    | SponsorLoaded ( Int, Result Http.Error Models.Sponsor )
    | TimeUpdate Time.Posix
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
