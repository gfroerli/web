module ViewTests exposing (suite)

import Expect exposing (Expectation)
import Html.Styled exposing (Html, p, text)
import Test exposing (..)
import Views exposing (splitParagraphsAndLinkify)


testSplitParagraphsAndLinkify : String -> List (Html msg) -> (() -> Expectation)
testSplitParagraphsAndLinkify given expected =
    \() ->
        Expect.equal (splitParagraphsAndLinkify given) expected


suite : Test
suite =
    describe "splitParagraphs"
        [ test "none" <|
            testSplitParagraphsAndLinkify
                "Hello"
                [ p [] [ text "Hello" ] ]
        , test "simple" <|
            testSplitParagraphsAndLinkify
                "He\nllo world"
                [ p [] [ text "He" ]
                , p [] [ text "llo world" ]
                ]
        , test "multiple" <|
            testSplitParagraphsAndLinkify
                "He\nl\nlo"
                [ p [] [ text "He" ]
                , p [] [ text "l" ]
                , p [] [ text "lo" ]
                ]
        , test "consecutive" <|
            testSplitParagraphsAndLinkify
                "He\n\nllo"
                [ p [] [ text "He" ]
                , p [] [ text "llo" ]
                ]
        ]
