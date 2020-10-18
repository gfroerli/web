module Helpers exposing (formatTemperature, isUrl, linkify)

import Html.Styled exposing (Html, a, text)
import Html.Styled.Attributes exposing (href)


primitiveRound : String -> Int -> Maybe String
primitiveRound val digits =
    case String.split "." val of
        [ t ] ->
            Just t

        [ integer, fractional ] ->
            Just <| integer ++ "." ++ String.left digits fractional

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


{-| Linkify a string, return a list of text or link elements.
-}
linkify : String -> List (Html msg)
linkify string =
    List.map linkifyWord (String.words string)


{-| Linkify a single word..

Return either a link element or a text element with a space appended.

-}
linkifyWord : String -> Html msg
linkifyWord word =
    if isUrl word then
        a [ href word ] [ text word ]

    else
        text word


{-| Return true if input value starts with `http://` or `https://`.
-}
isUrl : String -> Bool
isUrl value =
    let
        prefixes =
            [ "http://", "https://" ]
    in
    List.any (\prefix -> String.startsWith prefix value) prefixes
