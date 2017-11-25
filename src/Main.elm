module Main exposing (..)

import Css exposing (..)
import Css.Foreign as Foreign
import Css.Reset
import Html
import Html.Styled exposing (Html, toUnstyled)
import Html.Styled exposing (h1, h2, h3, h4, h5, h6, div, p, text)
import Html.Styled.Attributes as Attr exposing (id, class, css)
import Map
import MapPort


main =
    Html.program
        { init = init
        , view = view >> toUnstyled
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
        [ Css.Reset.css
        , Foreign.global
            [ Foreign.body <| fontBody ++ [ paddingTop (px 16), fontSize (px 16) ]
            , Foreign.h1 <| fontHeading ++ [ fontSize (em 3.4) ]
            , Foreign.h2 <| fontHeading ++ [ fontSize (em 2.2) ]
            , Foreign.h3 <| fontHeading ++ [ fontSize (em 1.6) ]
            , Foreign.h4 <| fontHeading ++ [ fontSize (em 1.3) ]
            , Foreign.p [ lineHeight (em 1.5) ]
            ]
        , div [ css [ width (pct 100) ] ]
            [ h1 [ css [ textAlign center, marginBottom (px 4) ] ] [ text "Gfrör.li" ]
            , h2 [ css [ textAlign center ] ] [ text "Wassertemperaturen Schweiz" ]
            ]
        , p [ css [ textAlign center, margin2 (px 16) zero ] ]
            [ text <|
                "Lat: "
                    ++ toString model.map.lat
                    ++ " | Lng: "
                    ++ toString model.map.lng
                    ++ " | Zoom: "
                    ++ toString model.map.zoom
            ]
        , div [ id "wrapper" ]
            [ div
                [ id "map"
                , css [ width (pct 100), height (px 600) ]
                ]
                []
            , div [ id "sidebar" ]
                [ h2 [] [ text "Details" ]
                , p [] [ text "Klicke auf einen Sensor, um mehr über ihn zu erfahren." ]
                ]
            ]
        ]


fontBody : List Style
fontBody =
    [ fontFamilies [ "Montserrat", .value sansSerif ]
    , color (rgb 50 50 50)
    ]


fontHeading : List Style
fontHeading =
    [ fontFamilies [ "Barlow Semi Condensed", .value sansSerif ]
    , color (rgb 50 50 50)
    ]
