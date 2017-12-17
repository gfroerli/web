module HelperTests exposing (..)

import Expect exposing (Expectation)
import Helpers exposing (..)
import Test exposing (..)


testFormatTemperature : String -> String -> (() -> Expectation)
testFormatTemperature given expected =
    \() ->
        Expect.equal (formatTemperature given) expected


suite : Test
suite =
    describe "formatTemperature"
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
