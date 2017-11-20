module Map exposing (Model, init)


type alias Model =
    { latitude : Float
    , longitude : Float
    , zoom : Float
    }


init : Model
init =
    { latitude = 47.227099
    , longitude = 8.822077
    , zoom = 12.0
    }
