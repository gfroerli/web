module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Map
import MapPort


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { map : Map.Model
    }


init : ( Model, Cmd Msg )
init =
    let
        map =
            Map.init
    in
        ( { map = map }
        , map
            |> MapPort.initializeMap
        )



-- UPDATE


type Msg
    = MapDragged Map.Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MapDragged pos ->
            let
                oldMap =
                    model.map

                newMap =
                    { oldMap
                        | lat = pos.lat
                        , lng = pos.lng
                        , zoom = pos.zoom
                    }
            in
                ( Model newMap, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    MapPort.mapMoved MapDragged



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Gfrör.li – Wassertemperaturen Schweiz" ]
        , p []
            [ text <|
                "Lat: "
                    ++ toString model.map.lat
                    ++ " | Lng: "
                    ++ toString model.map.lng
                    ++ " | Zoom: "
                    ++ toString model.map.zoom
            ]
        , div [ id "map" ] []
        ]
