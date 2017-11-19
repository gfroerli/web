module Map exposing (Model, JsObject, init, toJsObject, fromJsObject)


type alias Model =
    { latitude : Float
    , longitude : Float
    , zoom : Int
    }


init : Model
init =
    { latitude = 47.227099
    , longitude = 8.822077
    , zoom = 12
    }


type alias JsObject =
    { lat : Float
    , lng : Float
    , zoom : Int
    }


toJsObject : Model -> JsObject
toJsObject model =
    { lat = model.latitude
    , lng = model.longitude
    , zoom = model.zoom
    }


fromJsObject : JsObject -> Model
fromJsObject jsObj =
    { latitude = jsObj.lat
    , longitude = jsObj.lng
    , zoom = jsObj.zoom
    }
