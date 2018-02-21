module Messages exposing (..)

import Http
import Map
import Models
import Navigation exposing (Location)
import Time


type Msg
    = LocationChange Location
    | MapInitialized ()
    | MapDragged Map.Model
    | DataLoaded (Result Http.Error (List Models.Sensor))
    | SensorClicked (Maybe Models.JsSensor)
    | TimeUpdate Time.Time
