module Charts exposing (temperatureChart)

import Html exposing (Html, p, text)
import LineChart exposing (Config)
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Axis.Line as AxisLine
import LineChart.Axis.Range as Range
import LineChart.Axis.Ticks as Ticks
import LineChart.Axis.Title as Title
import LineChart.Colors as Colors
import LineChart.Container as Container
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk
import LineChart.Legends as Legends
import LineChart.Line as Line
import Models exposing (Measurement)
import Time exposing (Posix, posixToMillis, utc)


type alias Point =
    { x : Float, y : Float }


chartConfig : Range.Config -> Int -> Config Measurement msg
chartConfig range tickCount =
    let
        x_axis : Axis.Config Measurement msg
        x_axis =
            Axis.custom
                { title = Title.default ""
                , variable = Just << toFloat << posixToMillis << .createdAt
                , pixels = 500
                , range = range
                , axisLine = AxisLine.none
                , ticks = Ticks.time utc tickCount
                }

        y_axis : Axis.Config Measurement msg
        y_axis =
            Axis.custom
                { title = Title.default ""
                , variable = Just << .temperature
                , pixels = 300
                , range = Range.padded 20 20
                , axisLine =
                    AxisLine.custom <|
                        \dataRange axisRange ->
                            { color = Colors.grayLight
                            , width = 3
                            , events = []
                            , start = dataRange.min
                            , end = dataRange.max
                            }
                , ticks = Ticks.default
                }
    in
    { y = y_axis
    , x = x_axis
    , container =
        Container.custom
            { attributesHtml = []
            , attributesSvg = []
            , size = Container.relative
            , margin = Container.Margin 10 10 60 50
            , id = "line-chart-30d"
            }
    , interpolation = Interpolation.default
    , intersection = Intersection.default
    , legends = Legends.none
    , events = Events.default
    , junk = Junk.default
    , grid = Grid.lines 0.75 Colors.grayLight
    , area = Area.default
    , line = Line.wider 2
    , dots = Dots.custom (Dots.full 0)
    }


temperatureChart : Posix -> List Measurement -> Html msg
temperatureChart now measurements =
    let
        -- 1h offset / padding
        paddingMillis =
            1 * 1000 * 3600

        nowMillis =
            now |> posixToMillis

        range =
            Range.window
                ((nowMillis |> toFloat) - (1000 * 3600 * 24 * 3) - paddingMillis)
                ((nowMillis |> toFloat) + paddingMillis)

        -- We want to determine the number of ticks to show on the x axis
        -- depending on the amount of available data.
        -- Scale the number of ticks to ensure that the values are still readable.
        tickCount =
            case List.head measurements of
                Just measurement ->
                    let
                        createdMillis =
                            measurement.createdAt |> posixToMillis

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

                Nothing ->
                    0
    in
    LineChart.viewCustom
        (chartConfig range tickCount)
        [ LineChart.line Colors.blue Dots.circle "Temperature" measurements ]
