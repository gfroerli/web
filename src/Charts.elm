module Charts exposing (temperatureChart)

import Color
import Date exposing (toTime)
import Html exposing (Html)
import LineChart
import LineChart.Area as Area
import LineChart.Axis as Axis
import LineChart.Axis.Intersection as Intersection
import LineChart.Container as Container
import LineChart.Dots as Dots
import LineChart.Events as Events
import LineChart.Grid as Grid
import LineChart.Interpolation as Interpolation
import LineChart.Junk as Junk
import LineChart.Legends as Legends
import LineChart.Line as Line
import Models exposing (Measurement)


type alias Point =
    { x : Float, y : Float }


temperatureChart : List Measurement -> Html msg
temperatureChart measurements =
    LineChart.viewCustom
        { y = Axis.default 450 "°C" .temperature
        , x = Axis.default 700 "" (\m -> m.createdAt |> toTime)
        , container = Container.responsive "line-chart-1"
        , interpolation = Interpolation.default
        , intersection = Intersection.default
        , legends = Legends.none
        , events = Events.default
        , junk = Junk.default
        , grid = Grid.default
        , area = Area.default
        , line = Line.default
        , dots = Dots.default
        }
        [ LineChart.line Color.red Dots.circle "Foo" measurements ]
