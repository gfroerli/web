module Helpers exposing (formatTemperature, linkify)

import Html.Styled exposing (Html, text, a, div)
import Html.Styled.Attributes exposing (href)


primitiveRound : String -> Int -> Maybe String
primitiveRound val digits =
    case String.split "." val of
        [ t ] ->
            Just t

        [ integer, fractional ] ->
            Just <| integer ++ "." ++ (String.left 2 fractional)

        _ ->
            Nothing


{-| Format a temperature string. Cut off fractional part (if any) after 2 digits.

If the number is an invalid decimal (e.g. if it has two periods in it), the
string "invalid" is returned.

-}
formatTemperature : String -> String
formatTemperature temp =
    case primitiveRound temp 2 of
        Just t ->
            t ++ "°C"

        Nothing ->
            "invalid"


linkify : String -> Html msg
linkify string =
    div [] (List.map linkifyWord (String.words string))


linkifyWord : String -> Html msg
linkifyWord word =
    if isUrl word then
        a [href word] [text word]
    else
        text (word ++ " ")


isUrl : String -> Bool
isUrl =
    flip String.startsWith >> (flip List.any) [ "http://", "https://" ]
