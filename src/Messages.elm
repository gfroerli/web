module Messages exposing (..)

import Http
import Map
import Models
import Navigation exposing (Location)


type Msg
    = LocationChange Location
    | MapInitialized ()
    | MapDragged Map.Model
    | SensorsLoaded (Result Http.Error (List Models.Sensor))
    | MeasurementsLoaded (Result Http.Error (List Models.Measurement))
    | SensorClicked (Maybe Models.JsSensor)
