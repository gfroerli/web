module Charts exposing (temperatureChart)

import Axis
import Color
import Html exposing (Html, div, text)
import Models exposing (Measurement)
import Path exposing (Path)
import Scale exposing (ContinuousScale)
import Shape
import Time exposing (Posix)
import TypedSvg exposing (g, svg)
import TypedSvg.Attributes exposing (class, fill, stroke, transform, viewBox)
import TypedSvg.Attributes.InPx exposing (strokeWidth)
import TypedSvg.Core exposing (Svg)
import TypedSvg.Types exposing (Fill(..), Transform(..))


w : Float
w =
    420


h : Float
h =
    220


padding : Float
padding =
    30


colorLine : Color.Color
colorLine =
    Color.rgba 0.05098 0.27843 0.63137 1.0


colorArea : Color.Color
colorArea =
    Color.rgba 0.05098 0.27843 0.63137 0.3


{-| The X scale.

It starts with the first measurement timestamps and ends with now.

-}
xScale : Posix -> List Measurement -> ContinuousScale Time.Posix
xScale now measurements =
    let
        firstMeasurementTime =
            List.head measurements |> Maybe.map .createdAt

        -- If a first measurement is found, use it. Otherwise fall back to the
        -- current time.
        min =
            Maybe.withDefault now firstMeasurementTime

        max =
            now
    in
    Scale.time Time.utc
        ( 0, w - 2 * padding )
        ( min, max )


yScale : List Measurement -> ContinuousScale Float
yScale measurements =
    let
        temperatures =
            List.map .temperature measurements

        min =
            Maybe.withDefault 0 (List.minimum temperatures)

        max =
            Maybe.withDefault 20 (List.maximum temperatures)
    in
    Scale.linear
        ( h - 2 * padding, 0 )
        ( min, max )


xAxis : Posix -> List Measurement -> Svg msg
xAxis now measurements =
    let
        -- We want to determine the number of ticks to show on the x axis
        -- depending on the amount of available data.
        -- Scale the number of ticks to ensure that the values are still readable.
        tickCount =
            case List.head measurements of
                Just measurement ->
                    let
                        nowMillis =
                            now |> Time.posixToMillis

                        createdMillis =
                            measurement.createdAt |> Time.posixToMillis

                        hoursOfData =
                            toFloat (nowMillis - createdMillis) / 1000 / 3600
                    in
                    if hoursOfData > 60 then
                        5

                    else if hoursOfData > 48 then
                        4

                    else if hoursOfData > 36 then
                        3

                    else if hoursOfData > 24 then
                        2

                    else
                        1

                _ ->
                    0
    in
    Axis.bottom [ Axis.tickCount tickCount ] (xScale now measurements)


yAxis : List Measurement -> Svg msg
yAxis measurements =
    Axis.left [ Axis.tickCount 5 ] (yScale measurements)


transformToLineData : Posix -> List Measurement -> Measurement -> Maybe ( Float, Float )
transformToLineData now measurements measurement =
    Just
        ( Scale.convert (xScale now measurements) measurement.createdAt
        , Scale.convert (yScale measurements) measurement.temperature
        )


transformToAreaData : Posix -> List Measurement -> Measurement -> Maybe ( ( Float, Float ), ( Float, Float ) )
transformToAreaData now measurements measurement =
    Just
        ( ( Scale.convert (xScale now measurements) measurement.createdAt
          , Tuple.first (Scale.rangeExtent (yScale measurements))
          )
        , ( Scale.convert (xScale now measurements) measurement.createdAt
          , Scale.convert (yScale measurements) measurement.temperature
          )
        )


line : Posix -> List Measurement -> Path
line now measurements =
    List.map (transformToLineData now measurements) measurements
        |> Shape.line Shape.monotoneInXCurve


area : Posix -> List Measurement -> Path
area now measurements =
    List.map (transformToAreaData now measurements) measurements
        |> Shape.area Shape.monotoneInXCurve


temperatureChart : Maybe Posix -> List Measurement -> Html msg
temperatureChart maybeNow measurements =
    case maybeNow of
        Just now ->
            svg [ viewBox 0 0 w h ]
                [ g [ transform [ Translate (padding - 1) (h - padding) ] ]
                    [ xAxis now measurements ]
                , g [ transform [ Translate (padding - 1) padding ] ]
                    [ yAxis measurements ]
                , g [ transform [ Translate padding padding ], class [ "series" ] ]
                    [ Path.element (area now measurements) [ strokeWidth 3, fill <| Fill <| colorArea ]
                    , Path.element (line now measurements) [ stroke colorLine, strokeWidth 3, fill FillNone ]
                    ]
                ]

        Nothing ->
            div [] [ text "Missing time" ]
