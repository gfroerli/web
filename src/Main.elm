module Main exposing (..)

import Css exposing (..)
import Css.Foreign as Foreign
import Css.Reset
import Html
import Html.Styled exposing (Html, toUnstyled)
import Html.Styled exposing (h1, h2, h3, h4, h5, h6, div, p, text, button)
import Html.Styled.Attributes as Attr exposing (id, class, css)
import Html.Styled.Events as Events
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline as Pipeline
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
    , apiToken : String
    }


type alias Sensor =
    { id : Int
    , deviceName : String
    , caption : Maybe String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        map =
            Map.init
    in
        ( Model map flags.apiToken
        , map
            |> MapPort.initializeMap
        )



-- UPDATE


type Msg
    = LoadData String
    | DataLoaded (Result Http.Error (List Sensor))
    | MapDragged Map.Model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LoadData apiToken ->
            ( model, loadData apiToken )

        DataLoaded result ->
            let
                _ =
                    Debug.log "Loaded data:" result
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


loadData : String -> Cmd Msg
loadData apiToken =
    let
        url =
            "https://watertemp-api.coredump.ch/api/sensors"

        request =
            Http.request
                { method = "GET"
                , headers = getHeaders apiToken
                , url = url
                , body = Http.emptyBody
                , expect = Http.expectJson decodeApiResponse
                , timeout = Just (30 * Time.second)
                , withCredentials = False
                }
    in
        Http.send DataLoaded request


getHeaders : String -> List Http.Header
getHeaders apiToken =
    [ Http.header "Authorization" ("Bearer " ++ apiToken) ]


decodeApiResponse : Decoder (List Sensor)
decodeApiResponse =
    Decode.list sensorDecoder


subscriptions : Model -> Sub Msg
subscriptions model =
    MapPort.mapMoved MapDragged



-- DECODERS


sensorDecoder : Decoder Sensor
sensorDecoder =
    Pipeline.decode Sensor
        |> Pipeline.required "id" Decode.int
        |> Pipeline.required "device_name" Decode.string
        |> Pipeline.required "caption" (Decode.nullable Decode.string)



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
        , button [ Events.onClick (LoadData model.apiToken) ] [ text "Load data" ]
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
