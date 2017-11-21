module AppCss exposing (css)

import Css exposing (..)
import Css.Colors as Colors
import Css.Elements exposing (h1)
import Css.Namespace exposing (namespace)


css : Stylesheet
css =
    (stylesheet << namespace "gfr") <|
        List.concat
            [ [ h1 [ color Colors.blue ]
              , id "wrapper" [ displayFlex ]
              , id "map" [ width (pct 100), height (px 500) ]
              , id "sidebar"
                    [ minWidth (px 300)
                    , width (pct 30)
                    , padding (px 16)
                    ]
              ]
            ]
