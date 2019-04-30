module ViewTests exposing (suite)

import Expect exposing (Expectation)
import Html.Styled exposing (Html, p, text)
import Test exposing (..)
import Views exposing (splitParagraphs)


testSplitParagraphs : String -> List (Html msg) -> (() -> Expectation)
testSplitParagraphs given expected =
    \() ->
        Expect.equal (splitParagraphs given) expected


suite : Test
suite =
    describe "splitParagraphs"
        [ test "none" <|
            testSplitParagraphs
                "Hello"
                [ p [] [ text "Hello" ] ]
        , test "simple" <|
            testSplitParagraphs
                "He\nllo"
                [ p [] [ text "He" ]
                , p [] [ text "llo" ]
                ]
        , test "multiple" <|
            testSplitParagraphs
                "He\nl\nlo"
                [ p [] [ text "He" ]
                , p [] [ text "l" ]
                , p [] [ text "lo" ]
                ]
        , test "consecutive" <|
            testSplitParagraphs
                "He\n\nllo"
                [ p [] [ text "He" ]
                , p [] [ text "llo" ]
                ]
        ]
