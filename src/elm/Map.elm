module Map exposing (Model, Pos, init)


type alias Model =
    { lat : Float
    , lng : Float
    , zoom : Float
    }


init : Model
init =
    { lat = 47.099859
    , lng = 8.655552
    , zoom = 10.0
    }


type alias Pos =
    { lat : Float
    , lng : Float
    }
