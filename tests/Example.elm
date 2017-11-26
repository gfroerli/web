module Example exposing (..)

import Expect exposing (Expectation)
import Fuzz exposing (Fuzzer, int, list, string)
import Http
import Main exposing (..)
import Test exposing (..)


suite : Test
suite =
    describe "API"
        [ describe "Helper functions"
            [ test "getHeaders" <|
                \() ->
                    Expect.equal
                        (getHeaders "foo")
                        [ Http.header "Authorization" "Bearer foo" ]
            ]
        ]
