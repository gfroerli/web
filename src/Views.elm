module Views exposing (view)

import Css exposing (..)
import Css.Foreign as Foreign
import Css.Reset
import Helpers exposing (formatTemperature)
import Html.Styled exposing (Html)
import Html.Styled exposing (h1, h2, h3, h4, h5, h6, div, p, text, a, img, strong, footer)
import Html.Styled.Attributes as Attr exposing (id, class, css, src, href)
import Messages exposing (..)
import Models exposing (Model, Sensor)


view : Model -> Html Msg
view model =
    div
        [ css
            [ minHeight (vh 100)
            , displayFlex
            , flexDirection column
            ]
        ]
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
            [ text <|
                "Finde die aktuelle und historische Wassertemperatur an "
                    ++ (model.sensors |> List.length |> toString)
                    ++ " Standorten rund um den Zürichsee!"
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


sensorDescription : Sensor -> Html Msg
sensorDescription sensor =
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
                (\m ->
                    (p
                        [ css [ fontStyle normal ] ]
                        [ text (formatTemperature m.temperature) ]
                    )
                )
                sensor.lastMeasurement
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
