module Routing exposing
    ( Route(..)
    , aboutPath
    , coredumpPath
    , githubPath
    , mapPath
    , privacyPolicyPath
    , toRoute
    )

import Url
import Url.Parser exposing (Parser, map, oneOf, parse, s, top)


type Route
    = MapRoute
    | AboutRoute
    | PrivacyPolicyRoute
    | NotFoundRoute


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map MapRoute top
        , map AboutRoute (s "about")
        , map PrivacyPolicyRoute (s "privacy-policy")
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


privacyPolicyPath : String
privacyPolicyPath =
    "/privacy-policy"


githubPath : String
githubPath =
    "https://github.com/gfroerli/web"


coredumpPath : String
coredumpPath =
    "https://coredump.ch/"
