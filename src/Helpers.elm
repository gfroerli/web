module Helpers exposing (formatTemperature)


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
formatTemperature : Float -> String
formatTemperature temp =
    -- TODO: Use proper float rounding
    case primitiveRound (toString temp) 2 of
        Just t ->
            t ++ "°C"

        Nothing ->
            "invalid"
