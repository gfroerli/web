module HelperTests exposing (suite)

import Expect exposing (Expectation)
import Helpers exposing (..)
import Test exposing (..)


testFormatTemperature : String -> String -> (() -> Expectation)
testFormatTemperature given expected =
    \() ->
        Expect.equal (formatTemperature given) expected


testApproximateTimeAgo : Int -> String -> (() -> Expectation)
testApproximateTimeAgo given expected =
    \() ->
        Expect.equal (approximateTimeAgo given) expected


suite : Test
suite =
    describe "Helpers"
        [ describe "formatTemperature"
            [ test "roundDown" <|
                -- Decimal places are reduced to 2
                testFormatTemperature "13.1337" "13.13°C"
            , test "cutOff" <|
                -- Decimal places are cut off, not rounded
                testFormatTemperature "99.9999" "99.99°C"
            , test "singleFractional" <|
                -- Single fractional digits are left as-is
                testFormatTemperature "12.3" "12.3°C"
            , test "noFractionalPart" <|
                -- If there's no fractional part, number is returned as integer
                testFormatTemperature "99" "99°C"
            , test "invalidNumber" <|
                -- If the number is invalid, return "invalid"
                testFormatTemperature "99.9.9" "invalid"
            ]
        , describe "approximateTimeAgo"
            [ test "3 seconds" <|
                testApproximateTimeAgo 3 "Vor wenigen Sekunden"
            , test "29 seconds" <|
                testApproximateTimeAgo 29 "Vor wenigen Sekunden"
            , test "30 seconds" <|
                testApproximateTimeAgo 30 "Vor etwa einer Minute"
            , test "119 seconds" <|
                testApproximateTimeAgo 119 "Vor etwa einer Minute"
            , test "120 seconds" <|
                testApproximateTimeAgo 120 "Vor 2 Minuten"
            , test "58 minutes 50 seconds" <|
                testApproximateTimeAgo (58 * 60 + 50) "Vor 58 Minuten"
            , test "59 minutes 59 seconds" <|
                testApproximateTimeAgo (3600 - 1) "Vor 59 Minuten"
            , test "90 minutes" <|
                testApproximateTimeAgo (90 * 60) "Vor mehr als einer Stunde"
            , test "17 hours" <|
                testApproximateTimeAgo (17 * 3600 + 30) "Vor mehreren Stunden"
            , test "25 hours" <|
                testApproximateTimeAgo (25 * 3600) "Vor einem Tag"
            , test "48 hours" <|
                testApproximateTimeAgo (48 * 3600) "Vor 2 Tagen"
            , test "96 hours" <|
                testApproximateTimeAgo (96 * 3600) "Vor 4 Tagen"
            , test "8 days" <|
                testApproximateTimeAgo (24 * 3600 * 8) "Vor mehr als einer Woche"
            , test "32 days" <|
                testApproximateTimeAgo (24 * 3600 * 32) "Vor mehr als einem Monat"
            , test "120 days" <|
                testApproximateTimeAgo (24 * 3600 * 120) "Vor langer Zeit"
            ]
        ]
