module Routing exposing
    ( Route(..)
    , aboutPath
    , coredumpPath
    , getSensorId
    , githubPath
    , mapPath
    , privacyPolicyPath
    , routeNeedsMap
    , sensorPath
    , toRoute
    )

import Url
import Url.Parser exposing ((</>), Parser, int, map, oneOf, parse, s, top)


type Route
    = MapRoute
    | SensorRoute Int
    | AboutRoute
    | PrivacyPolicyRoute
    | NotFoundRoute


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map MapRoute top
        , map SensorRoute (s "sensor" </> int)
        , map AboutRoute (s "about")
        , map PrivacyPolicyRoute (s "privacy-policy")
        ]


toRoute : Url.Url -> Route
toRoute url =
    Maybe.withDefault NotFoundRoute (parse routeParser url)


{-| Return whether or not this route requires an initialized map.
-}
routeNeedsMap : Route -> Bool
routeNeedsMap route =
    case route of
        MapRoute ->
            True

        SensorRoute _ ->
            True

        _ ->
            False


getSensorId : Route -> Maybe Int
getSensorId route =
    case route of
        SensorRoute sensorId ->
            Just sensorId

        _ ->
            Nothing



-- Helper functions that return certain paths.


mapPath : String
mapPath =
    "/"


sensorPath : Int -> String
sensorPath sensorId =
    "/sensor/" ++ String.fromInt sensorId


aboutPath : String
aboutPath =
    "/about"


privacyPolicyPath : String
privacyPolicyPath =
    "/privacy-policy"


githubPath : String
githubPath =
    "https://github.com/gfroerli/web"


coredumpPath : String
coredumpPath =
    "https://coredump.ch/"
