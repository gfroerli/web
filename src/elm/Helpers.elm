module Helpers exposing (approximateTimeAgo, formatTemperature, posixTimeDeltaSeconds)

import Time


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
            t ++ " °C"

        Nothing ->
            "invalid"


{-| Return (time2 - time1) in seconds.
-}
posixTimeDeltaSeconds : Time.Posix -> Time.Posix -> Int
posixTimeDeltaSeconds time1 time2 =
    (Time.posixToMillis time2 - Time.posixToMillis time1) // 1000


{-| Format approximate time in seconds, relative to now.

Note: Currently not internationalized, returning German durations only.

-}
approximateTimeAgo : Int -> String
approximateTimeAgo secondsAgo =
    if secondsAgo < 30 then
        "vor wenigen Sekunden"

    else if secondsAgo < 120 then
        "vor etwa einer Minute"

    else if secondsAgo < 3600 then
        "vor " ++ String.fromInt (secondsAgo // 60) ++ " Minuten"

    else if secondsAgo < 7200 then
        "vor mehr als einer Stunde"

    else if secondsAgo < (24 * 3600) then
        "vor mehreren Stunden"

    else if secondsAgo < (24 * 3600 * 2) then
        "vor einem Tag"

    else if secondsAgo < (24 * 3600 * 7) then
        "vor " ++ String.fromInt (secondsAgo // 3600 // 24) ++ " Tagen"

    else if secondsAgo < (24 * 3600 * 30) then
        "vor mehr als einer Woche"

    else if secondsAgo < (24 * 3600 * 30 * 3) then
        "vor mehr als einem Monat"

    else
        "vor langer Zeit"
