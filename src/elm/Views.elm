module Views exposing (splitParagraphs, view)

import Browser
import Charts exposing (temperatureChart)
import Css exposing (..)
import Css.Global as Global
import Css.Media as Media
import Helpers exposing (approximateTimeAgo, formatTemperature, posixTimeDeltaSeconds)
import Html.Styled exposing (Attribute, Html, a, div, footer, fromUnstyled, h1, h2, h3, img, li, p, span, text, toUnstyled, ul)
import Html.Styled.Attributes exposing (alt, css, href, id, src)
import Material.Icons.Outlined as Outlined
import Material.Icons.Types exposing (Coloring(..))
import Messages exposing (..)
import Models exposing (Alert, DelayedSponsor, Model, SensorDetails, Severity(..))
import Routing exposing (Route(..))
import Time


{-| Root view.

Decide which view to render based on the current route.

-}
view : Model -> Browser.Document Msg
view model =
    let
        body =
            case model.route of
                MapRoute ->
                    mapView model

                AboutRoute ->
                    aboutView

                PrivacyPolicyRoute ->
                    privacyPolicyView

                NotFoundRoute ->
                    notFoundView
    in
    { title = "Gfrörli – Wassertemperatur Schweiz"
    , body = [ toUnstyled body ]
    }


{-| Wrap a list of HTML elements in a wrapper div with full height.
-}
page : String -> List Alert -> List (Html Msg) -> Html Msg
page subtitle alerts elements =
    div
        [ css
            [ height (vh 100)
            , displayFlex
            , flexDirection column
            ]
        ]
        (List.append
            [ Global.global
                [ -- Layout
                  Global.id "main" [ minHeight (vh 100) ]

                -- Typography
                , Global.body <| fontBody ++ [ fontSize (px 16) ]
                , Global.h1 <| fontHeading ++ [ fontSize (em 3.4), marginBottom (px 16) ]
                , Global.h2 <| fontHeading ++ [ fontSize (em 2.2), marginBottom (px 8) ]
                , Global.h3 <| fontHeading ++ [ fontSize (em 1.6), marginBottom (px 8), marginTop (px 32) ]
                , Global.h4 <| fontHeading ++ [ fontSize (em 1.3) ]
                , Global.p [ lineHeight (em 1.5), marginBottom (px 8) ]
                , Global.strong [ fontWeight bold ]

                -- Lists
                , Global.li [ listStyleType disc, listStylePosition inside ]

                -- Map markers
                , Global.class "marker"
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
                    , Global.withClass "selected"
                        [ backgroundImage (url "/static/marker-selected.svg") ]
                    ]

                -- Media queries: Avoid download buttons overlapping with header
                , Global.media [ Media.only Media.screen [ Media.maxWidth (px 900) ] ]
                    [ Global.id "download-buttons"
                        [ position static
                        , margin2 zero auto
                        , marginBottom (px 16)
                        ]
                    ]
                , Global.media [ Media.only Media.screen [ Media.maxWidth (px 900) ] ]
                    [ Global.selector "#download-buttons img"
                        [ height (px 40)
                        ]
                    ]

                -- Media queries: Make sidebar larger on small devices
                , Global.media [ Media.only Media.screen [ Media.maxWidth (px 1600) ] ] [ Global.id "sidebar" [ flexBasis (pct 30) ] ]
                , Global.media [ Media.only Media.screen [ Media.maxWidth (px 900) ] ] [ Global.id "sidebar" [ flexBasis (pct 50) ] ]

                -- Media queries: Reduce title size on small devices
                , Global.media [ Media.only Media.screen [ Media.maxWidth (px 500) ] ] [ Global.h1 [ fontSize (em 2), marginBottom (px 8) ] ]
                , Global.media [ Media.only Media.screen [ Media.maxWidth (px 500) ] ] [ Global.h2 [ fontSize (em 1.3), marginBottom (px 8) ] ]
                , Global.media [ Media.only Media.screen [ Media.maxWidth (px 500) ] ] [ Global.h3 [ fontSize (em 1.1), marginBottom (px 8) ] ]
                ]
            , div [ css [ width (pct 100), marginTop (px 16) ] ]
                [ h1 [ css [ textAlign center, marginBottom (px 4) ] ] [ text "Gfrör.li" ]
                , h2 [ css [ textAlign center ] ] [ text "Wassertemperaturen Schweiz" ]
                ]
            , p [ css [ textAlign center, margin2 (px 16) zero ] ]
                [ text subtitle ]
            , alertMessages alerts
            ]
            elements
        )


styleMessage : Alert -> List (Attribute Msg)
styleMessage alert =
    case alert.severity of
        Error ->
            [ css
                [ color (hex "#ffffff")
                , backgroundColor (hex "#c62828")
                , textAlign center
                , padding (px 8)
                ]
            ]


{-| Alert messages shown to the user (e.g. errors)
-}
alertMessages : List Alert -> Html Msg
alertMessages alerts =
    div [ id "alerts" ]
        (List.map
            (\alert ->
                p (styleMessage alert)
                    [ span [ css [ fontWeight bold ] ] [ text "Fehler: " ]
                    , text alert.message
                    ]
            )
            alerts
        )


{-| View: Not found
-}
notFoundView : Html Msg
notFoundView =
    page
        ""
        []
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
        []
        [ div
            [ css [ maxWidth (px 800), paddingLeft (px 8), paddingRight (px 8), margin2 zero auto, textAlign center ] ]
            [ h2 [] [ text "About" ]
            , h3 [ css [] ] [ text "Warum dieses Projekt?" ]
            , p [] [ text "Die Wassertemperatur ist für viele Menschen ein wichtiger Wert, zum Beispiel für Schwimmer, Taucher, Fischer und viele mehr. Aber bisher gab es keine verlässliche Methode, um Echtzeit-Temperaturinformationen in deiner Gegend zu erhalten." ]
            , p [] [ text "Es gibt heute bereits ein paar Wassertemperatur-Sensor-Netzwerke, aber meistens gibt es nur einen Sensor pro See, wodurch lokale Temperaturunterschiede (z.B. an einer Flussmündung) ignoriert werden. Viele Sensoren werden zudem nur ein mal pro Tag publiziert." ]
            , p [] [ text "Wir bauen ein Netzwerk von kostengünstigen Wassertemperatur-Sensoren mit sehr geringem Energieverbrauch auf.  Dies ermöglicht uns, die Wassertemperatur lokal zu messen und sie dir kostenlos in Quasi-Echtzeit anzuzeigen." ]
            , p []
                [ text "Der Quellcode dieser Webapp steht unter einer freien Lizenz und kann "
                , a [ href Routing.githubPath ] [ text "auf Github" ]
                , text " eingesehen und verbessert werden!"
                ]
            , h3 [ css [] ] [ text "Wer hat diese Website entwickelt?" ]
            , p [] [ text "Diese Website, die Server-Infrastruktur wie auch die Sensor-Hardware werden vom Coredump Hackerspace in Rapperswil-Jona entwickelt." ]
            , p []
                [ text "Mehr Informationen über uns findest du auf unserer Website: "
                , a [ href Routing.coredumpPath ] [ text "www.coredump.ch" ]
                ]
            , h3 [ css [] ] [ text "Wie kann ich selber so einen Sensor platzieren?" ]
            , p []
                [ text "Kontaktiere uns doch unter "
                , a [ href "mailto:gfroerli@coredump.ch" ] [ text "gfroerli@coredump.ch" ]
                , text "!"
                ]
            , a [ href Routing.mapPath, css [ display inlineBlock, marginTop (px 32) ] ] [ text "Zurück zur Karte" ]
            ]
        ]


{-| View: Privacy Policy
-}
privacyPolicyView : Html Msg
privacyPolicyView =
    page
        ""
        []
        [ div
            [ css [ maxWidth (px 800), paddingLeft (px 8), paddingRight (px 8), margin2 zero auto, textAlign center ] ]
            [ h2 [] [ text "Privacy Policy (Apps / Web)" ]
            , p [] [ text "Verein Coredump built the Gfrörli apps and website as Open Source apps and website. This service is provided by Verein Coredump at no cost and is intended for use as is." ]
            , p [] [ text "This page is used to inform visitors regarding our policies with the collection, use, and disclosure of Personal Information if anyone decided to use our Service." ]
            , h3 [ css [] ] [ text "Information Collection and Use" ]
            , p [] [ text "We do not collect any personally identifiable information." ]
            , p [] [ text "Crash reports are not collected by the app itself, but may be collected and submitted through your mobile operating system at your choice." ]
            , h3 [ css [] ] [ text "Cookies" ]
            , p [] [ text "Our website does not use any cookies for tracking or analytics purposes." ]
            , h3 [ css [] ] [ text "Service Providers" ]
            , p [] [ text "Our Android and Web applications make use of the following service providers:" ]
            , ul []
                [ li [] [ text "Map tiles provided by Mapbox" ]
                ]
            , h3 [ css [] ] [ text "Changes to This Privacy Policy" ]
            , p [] [ text "We may update our Privacy Policy from time to time. Thus, you are advised to review this page periodically for any changes. We will notify you of any changes by posting the new Privacy Policy on this page." ]
            , h3 [ css [] ] [ text "Contact Us" ]
            , p [] [ text "If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at gfroerli@coredump.ch!" ]
            , p [ css [ fontStyle italic, marginTop (px 32) ] ] [ text "This policy is effective as of 2022-07-28" ]
            , a [ href Routing.mapPath, css [ display inlineBlock, marginTop (px 32) ] ] [ text "Back" ]
            ]
        ]


pluralize : String -> String -> Int -> String
pluralize singular plural quantity =
    if quantity == 1 then
        singular

    else
        plural


{-| View: Map
-}
mapView : Model -> Html Msg
mapView model =
    page
        ("Finde die aktuelle und historische Wassertemperatur an "
            ++ (model.sensors |> List.length |> String.fromInt)
            ++ pluralize " Standort" " Standorten" (model.sensors |> List.length)
            ++ " in verschiedenen Seen der Schweiz!"
        )
        model.alerts
        [ div [ id "download-buttons", css [ position absolute, top (px 8), right (px 8) ] ]
            [ a
                [ href "https://play.google.com/store/apps/details?id=ch.coredump.watertemp.zh" ]
                [ img [ src "/static/google-play-badge.png" ] [] ]
            , a
                [ href "https://apps.apple.com/us/app/gfr%C3%B6r-li/id1451431723" ]
                [ img [ src "/static/AppStoreBadge.png", css [ marginLeft (px 8), height (px 50) ] ] [] ]
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
                , overflow hidden
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
                    , overflowY auto
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
            [ text "© 2017–2023 Coredump Rapperswil-Jona"
            , text " | "
            , a [ href Routing.aboutPath ] [ text "About" ]
            , text " | "
            , a [ href Routing.privacyPolicyPath ] [ text "Privacy Policy" ]
            , text " | "
            , a [ href Routing.githubPath ] [ text "Code on Github" ]
            ]
        ]


sidebarContents : Model -> List (Html Msg)
sidebarContents model =
    let
        headingStyle =
            [ css [ marginBottom (em 0.5) ] ]
    in
    case ( model.selectedSensor, model.now ) of
        ( Models.SensorMissing, _ ) ->
            [ h2 headingStyle [ text "Details" ]
            , p [] [ text "Klicke auf einen Sensor, um mehr über ihn zu erfahren." ]
            ]

        ( Models.SensorLoading, _ ) ->
            [ h2 headingStyle [ text "Details" ]
            , p [] [ text "Sensor wird geladen..." ]
            ]

        ( Models.SensorLoaded _, Nothing ) ->
            [ h2 headingStyle [ text "Details" ]
            , p [] [ text "Aktuelle Uhrzeit wird geladen..." ]
            ]

        ( Models.SensorLoaded sensor, Just now ) ->
            [ h2 headingStyle [ text sensor.deviceName ]
            , sensorDescription now
                sensor
                model.selectedSponsor
            ]


sensorDescription : Time.Posix -> SensorDetails -> DelayedSponsor -> Html Msg
sensorDescription now sensor sponsor =
    let
        lastMeasurementTimeAgo =
            Maybe.map
                (\latestMeasurementAt -> posixTimeDeltaSeconds latestMeasurementAt now |> approximateTimeAgo)
                sensor.latestMeasurementAt
    in
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
                    p
                        [ css [ fontStyle normal ] ]
                        [ text s ]
                )
                sensor.caption
            )
        , case ( sensor.latestTemperature, lastMeasurementTimeAgo ) of
            ( Just temperature, Just timeAgo ) ->
                let
                    temperatureString =
                        temperature |> String.fromFloat |> formatTemperature
                in
                p
                    [ css [ fontStyle normal ] ]
                    [ span
                        [ css
                            [ position relative
                            , top (px 2)
                            , marginRight (px 4)
                            ]
                        ]
                        [ fromUnstyled <| Outlined.thermostat 16 Inherit ]
                    , text <| temperatureString ++ " (" ++ timeAgo ++ ")"
                    ]

            _ ->
                p
                    [ css [ fontStyle italic ] ]
                    [ text "Keine Messung" ]
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
                                [ text "Keine Messungen in den letzten 3 Tagen" ]

                        mm ->
                            fromUnstyled <| temperatureChart now mm
                )
                sensor.historicMeasurements
            )
        , h3 [] [ text "Statistiken (Alle Messungen)" ]
        , case ( sensor.minimumTemperature, sensor.maximumTemperature, sensor.averageTemperature ) of
            ( Just min, Just max, Just avg ) ->
                p []
                    [ text <| "Min: " ++ (min |> String.fromFloat |> formatTemperature)
                    , text " | "
                    , text <| "Max: " ++ (max |> String.fromFloat |> formatTemperature)
                    , text " | "
                    , text <| "Avg: " ++ (avg |> String.fromFloat |> formatTemperature)
                    ]

            _ ->
                p [ css [ fontStyle italic ] ] [ text "Keine Statistiken vorhanden" ]
        , case sponsor of
            Models.SponsorLoaded sp ->
                h3 [] [ text <| "Sponsor: " ++ sp.name ]

            _ ->
                h3 [] [ text "Sponsor" ]
        , case sponsor of
            Models.SponsorMissing ->
                p [ css [ fontStyle italic ] ] [ text "Kein Sponsor gefunden" ]

            Models.SponsorLoading ->
                p
                    [ css [ fontStyle italic ] ]
                    [ text "Sponsor wird geladen..." ]

            Models.SponsorLoaded sp ->
                let
                    intro =
                        p [] [ text <| "Dieser Sponsor wird von \"" ++ sp.name ++ "\" gesponsert." ]

                    logo =
                        Maybe.map
                            (\url ->
                                img
                                    [ src url
                                    , alt (sp.name ++ " Logo")
                                    , css [ width (pct 70), marginTop (px 16), marginBottom (px 24), marginLeft (px 24) ]
                                    ]
                                    []
                            )
                            sp.logo_url
                in
                div [ css [ displayFlex, flexDirection column ] ] <|
                    List.append
                        -- Intro and logo
                        (List.filterMap (\x -> x) [ Just intro, logo ])
                        -- Description paragraph(s)
                        (splitParagraphs sp.description)
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


{-| Split text at newline characters, create paragraphs
-}
splitParagraphs : String -> List (Html msg)
splitParagraphs str =
    let
        isNotEmpty =
            not << String.isEmpty

        parts =
            List.filter isNotEmpty (String.split "\n" str)

        textToParagraph =
            \t -> p [] [ text t ]
    in
    List.map textToParagraph parts
