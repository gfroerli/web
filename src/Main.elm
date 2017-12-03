module Main exposing (..)

import Api
import Css exposing (..)
import Css.Foreign as Foreign
import Css.Reset
import Html
import Html.Styled exposing (Html, toUnstyled)
import Html.Styled exposing (h1, h2, h3, h4, h5, h6, div, p, text, a, img, strong)
import Html.Styled.Attributes as Attr exposing (id, class, css, src, href)
import Http
import Json.Decode as Decode
import List.Extra exposing (find)
import Map
import MapPort
import Time


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view >> toUnstyled
        , update = update
        , subscriptions = subscriptions
        }


type alias Flags =
    { apiToken : String
    }



-- MODEL


type alias Model =
    { map : Map.Model
    , sensors : List Api.Sensor
    , selectedSensor : Maybe Api.Sensor
    , apiToken : String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        map =
            Map.init
    in
        ( Model map [] Nothing flags.apiToken
        , MapPort.initializeMap map
        )



-- UPDATE


type Msg
    = MapInitialized ()
    | MapDragged Map.Model
    | DataLoaded (Result Http.Error (List Api.Sensor))
    | SensorClicked (Maybe Api.JsSensor)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MapInitialized _ ->
            ( model, loadData model.apiToken )

        DataLoaded result ->
            case result of
                Ok sensors ->
                    ( { model | selectedSensor = Nothing, sensors = sensors }
                    , List.map Api.toJsSensor sensors
                        |> MapPort.sensorsLoaded
                    )

                Err error ->
                    let
                        _ =
                            -- TODO
                            Debug.log "Error while fetching data" error
                    in
                        ( model, Cmd.none )

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
                ( { model | map = newMap }, Cmd.none )

        SensorClicked (Just jsSensor) ->
            let
                selectedSensor =
                    find (\sensor -> sensor.id == jsSensor.id)
                        model.sensors
            in
                ( { model | selectedSensor = selectedSensor }, Cmd.none )

        SensorClicked Nothing ->
            ( { model | selectedSensor = Nothing }, Cmd.none )


loadData : String -> Cmd Msg
loadData apiToken =
    let
        url =
            "https://watertemp-api.coredump.ch/api/sensors"

        request =
            Http.request
                { method = "GET"
                , headers = Api.getHeaders apiToken
                , url = url
                , body = Http.emptyBody
                , expect = Http.expectJson (Decode.list Api.sensorDecoder)
                , timeout = Just (30 * Time.second)
                , withCredentials = False
                }
    in
        Http.send DataLoaded request


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ MapPort.mapInitialized MapInitialized
        , MapPort.mapMoved MapDragged
        , MapPort.sensorClicked SensorClicked
        ]



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
            , Foreign.strong [ fontWeight bold ]
            , Foreign.class "marker"
                [ backgroundImage (url "/static/marker.svg")
                , backgroundSize cover
                , width (px 32)
                , height (px 32)
                , lineHeight (px 32)
                , cursor pointer
                , textAlign center
                , verticalAlign middle
                , fontWeight bold
                , fontSize (px 16)
                ]
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
                    ++ " | Selected sensor: "
                    ++ case model.selectedSensor of
                        Just x ->
                            toString x.id

                        Nothing ->
                            "None"
            ]
        , div [ css [ position absolute, top (px 8), right (px 8) ] ]
            [ a
                [ href "https://play.google.com/apps/testing/ch.coredump.watertemp.zh" ]
                [ img [ src "/static/google-play-badge.png" ] [] ]
            ]
        , div
            [ id "wrapper"
            , css
                [ position relative
                , height (pct 100)
                , minHeight (px 500)
                , width (pct 100)
                , displayFlex
                , flexDirection row
                , alignItems stretch
                ]
            ]
            [ div
                [ id "mapContainer"
                , css
                    [ position relative
                    , flexGrow (num 1)
                    ]
                ]
                [ div
                    [ id "map"
                    , css
                        [ position absolute
                        , top zero
                        , bottom zero
                        , left zero
                        , right zero
                        ]
                    ]
                    []
                ]
            , div
                [ id "sidebar"
                , css
                    [ flexBasis (pct 20)
                    , padding (px 16)
                    , backgroundColor (hex "#F7F7F7")
                    ]
                ]
                (sidebarContents model)
            ]
        ]


sidebarContents : Model -> List (Html Msg)
sidebarContents model =
    [ h2
        [ css [ marginBottom (em 0.5) ] ]
        [ text <| Maybe.withDefault "Details" (Maybe.map .deviceName model.selectedSensor) ]
    , Maybe.withDefault
        (p [] [ text "Klicke auf einen Sensor, um mehr über ihn zu erfahren." ])
        (Maybe.map sensorDescription model.selectedSensor)
    ]


sensorDescription : Api.Sensor -> Html Msg
sensorDescription sensor =
    div []
        [ Maybe.withDefault
            (p [] [ text "Keine Beschreibung" ])
            (Maybe.map (\s -> (p [] [ text s ])) sensor.caption)
        ]


{-| Font related styling rules for the entire body
-}
fontBody : List Style
fontBody =
    [ fontFamilies [ "Montserrat", .value sansSerif ]
    , color (rgb 50 50 50)
    ]


{-| Font related styling rules for all headings
-}
fontHeading : List Style
fontHeading =
    [ fontFamilies [ "Barlow Semi Condensed", .value sansSerif ]
    , color (rgb 50 50 50)
    ]
