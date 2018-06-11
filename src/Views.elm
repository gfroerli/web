module Views exposing (view)

import Charts exposing (temperatureChart)
import Css exposing (..)
import Css.Foreign as Foreign
import Css.Reset
import Helpers exposing (formatTemperature)
import Html.Styled exposing (Html, fromUnstyled)
import Html.Styled exposing (h1, h2, h3, h4, h5, h6, div, p, text, a, img, strong, footer)
import Html.Styled.Attributes as Attr exposing (id, class, css, src, href)
import Messages exposing (..)
import Models exposing (Model, Sensor, Route(..))
import Routing
import Time exposing (Time)


{-| Root view.

Decide which view to render based on the current route.

-}
view : Model -> Html Msg
view model =
    case model.route of
        MapRoute ->
            mapView model

        AboutRoute ->
            aboutView

        NotFoundRoute ->
            notFoundView


{-| Wrap a list of HTML elements in a wrapper div with full height.
-}
page : String -> List (Html Msg) -> Html Msg
page subtitle elements =
    div
        [ css
            [ minHeight (vh 100)
            , displayFlex
            , flexDirection column
            ]
        ]
        (List.append
            [ Css.Reset.css
            , Foreign.global
                [ Foreign.body <| fontBody ++ [ fontSize (px 16) ]
                , Foreign.id "main" [ minHeight (vh 100) ]
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
                    , Foreign.withClass "selected"
                        [ backgroundImage (url "/static/marker-selected.svg") ]
                    ]
                ]
            , div [ css [ width (pct 100), marginTop (px 16) ] ]
                [ h1 [ css [ textAlign center, marginBottom (px 4) ] ] [ text "Gfrör.li" ]
                , h2 [ css [ textAlign center ] ] [ text "Wassertemperaturen Schweiz" ]
                ]
            , p [ css [ textAlign center, margin2 (px 16) zero ] ]
                [ text subtitle ]
            ]
            elements
        )


{-| View: Not found
-}
notFoundView : Html Msg
notFoundView =
    page
        ""
        [ div [ css [ width (pct 100), textAlign center ] ]
            [ p
                [ css [ fontSize (em 12) ] ]
                [ text "404" ]
            , p
                [ css [ fontSize (em 1.2) ] ]
                [ text "Es tut uns leid, aber die gewünschte Seite wurde nicht gefunden." ]
            ]
        ]


{-| View: About
-}
aboutView : Html Msg
aboutView =
    page
        ""
        [ div
            [ css [ width (px 800), margin2 zero auto, textAlign center ] ]
            [ h2 [ css [ marginBottom (px 16) ] ] [ text "About" ]
            , p [] [ text "Gfrör.li ist ein Projekt des Hackerspaces \"Coredump\" in Rapperswil-Jona." ]
            , p []
                [ text "Der Quellcode dieser Webapp steht unter einer freien Lizenz und kann "
                , a [ href Routing.githubPath ] [ text "auf Github" ]
                , text " eingesehen und verbessert werden!"
                ]
            , a [ href Routing.mapPath ] [ text "Zurück zur Karte" ]
            ]
        ]


{-| View: Map
-}
mapView : Model -> Html Msg
mapView model =
    page
        ("Finde die aktuelle und historische Wassertemperatur an "
            ++ (model.sensors |> List.length |> toString)
            ++ " Standorten rund um den Zürichsee!"
        )
        [ div [ css [ position absolute, top (px 8), right (px 8) ] ]
            [ a
                [ href "https://play.google.com/apps/testing/ch.coredump.watertemp.zh" ]
                [ img [ src "/static/google-play-badge.png" ] [] ]
            ]
        , div
            [ id "wrapper"
            , css
                [ position relative
                , width (pct 100)
                , flexGrow (num 1)
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
        , footer
            [ css
                [ fontSize (em 0.8)
                , textAlign center
                , padding2 (px 8) zero
                ]
            ]
            [ text "© 2017 Coredump Rapperswil-Jona"
            , text " | "
            , a [ href Routing.aboutPath ] [ text "About" ]
            , text " | "
            , a [ href Routing.githubPath ] [ text "Code on Github" ]
            ]
        ]


sidebarContents : Model -> List (Html Msg)
sidebarContents model =
    [ h2
        [ css [ marginBottom (em 0.5) ] ]
        [ text <| Maybe.withDefault "Details" (Maybe.map .deviceName model.selectedSensor) ]
    , Maybe.withDefault
        (p [] [ text "Klicke auf einen Sensor, um mehr über ihn zu erfahren." ])
        (Maybe.map (\s -> sensorDescription model.now s) model.selectedSensor)
    ]


sensorDescription : Maybe Time -> Sensor -> Html Msg
sensorDescription now sensor =
    div []
        [ Maybe.withDefault
            -- Fallback if there is no caption
            (p
                [ css [ fontStyle italic ] ]
                [ text "Keine Beschreibung" ]
            )
            -- Extract and show caption
            (Maybe.map
                (\s ->
                    (p
                        [ css [ fontStyle normal ] ]
                        [ text s ]
                    )
                )
                sensor.caption
            )
        , h3 [] [ text "Letzte Messung" ]
        , Maybe.withDefault
            -- Fallback if there is no measurement
            (p
                [ css [ fontStyle italic ] ]
                [ text "Keine Messung" ]
            )
            -- Extract and show last measurement
            (Maybe.map
                (\measurement ->
                    (p
                        [ css [ fontStyle normal ] ]
                        [ text (measurement.temperature |> toString |> formatTemperature) ]
                    )
                )
                sensor.lastMeasurement
            )
        , h3 [] [ text "Temperaturverlauf (3 Tage)" ]
        , Maybe.withDefault
            -- Fallback if there are no historic measurements
            (p
                [ css [ fontStyle italic ] ]
                [ text "Temperaturverlauf wird geladen..." ]
            )
            -- Extract and show historic measurements
            (Maybe.map
                (\measurements ->
                    case measurements of
                        [] ->
                            p
                                [ css [ fontStyle italic ] ]
                                [ text "No recent measurements" ]

                        mm ->
                            fromUnstyled <| temperatureChart now mm
                )
                sensor.historicMeasurements
            )
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
