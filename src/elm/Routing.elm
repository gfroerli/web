module Routing exposing
    ( Route(..)
    , aboutPath
    , coredumpPath
    , githubPath
    , mapPath
    , toRoute
    )

import Browser.Navigation as Nav
import Url
import Url.Parser exposing (Parser, map, oneOf, parse, s, top)


type Route
    = MapRoute
    | AboutRoute
    | NotFoundRoute


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map MapRoute top
        , map AboutRoute (s "about")
        ]


toRoute : Url.Url -> Route
toRoute url =
    Maybe.withDefault NotFoundRoute (parse routeParser url)



-- Helper functions that return certain paths.


mapPath : String
mapPath =
    "/"


aboutPath : String
aboutPath =
    "/about"


githubPath : String
githubPath =
    "https://github.com/coredump-ch/water-sensor-web"


coredumpPath : String
coredumpPath =
    "https://coredump.ch/"
