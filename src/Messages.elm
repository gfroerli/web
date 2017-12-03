module Messages exposing (..)

import Api
import Http
import Map


type Msg
    = MapInitialized ()
    | MapDragged Map.Model
    | DataLoaded (Result Http.Error (List Api.Sensor))
    | SensorClicked (Maybe Api.JsSensor)
