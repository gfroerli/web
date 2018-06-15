module Routing
    exposing
        ( parseLocation
        , mapPath
        , aboutPath
        , githubPath
        , coredumpPath
        )

import Models exposing (Route(..))
import Navigation exposing (Location)
import UrlParser exposing (Parser, oneOf, parseHash, map, top, s)


matchers : Parser (Route -> a) a
matchers =
    oneOf
        [ map MapRoute top
        , map AboutRoute (s "about")
        ]


parseLocation : Location -> Route
parseLocation location =
    case (parseHash matchers location) of
        Just route ->
            route

        Nothing ->
            NotFoundRoute


mapPath : String
mapPath =
    "#/"


aboutPath : String
aboutPath =
    "#/about"


githubPath : String
githubPath =
    "https://github.com/coredump-ch/water-sensor-web"


coredumpPath : String
coredumpPath =
    "https://coredump.ch/"
