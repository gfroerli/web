module Map exposing (Model, Pos, init)


type alias Model =
    { lat : Float
    , lng : Float
    , zoom : Float
    }


init : Model
init =
    { lat = 47.227099
    , lng = 8.822077
    , zoom = 12.0
    }


type alias Pos =
    { lat : Float
    , lng : Float
    }
