module Messages exposing (..)

import Http
import Map
import Models


type Msg
    = MapInitialized ()
    | MapDragged Map.Model
    | DataLoaded (Result Http.Error (List Models.Sensor))
    | SensorClicked (Maybe Models.JsSensor)
