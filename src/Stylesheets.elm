port module Stylesheets exposing (..)

import AppCss
import Css exposing (Stylesheet)
import Css.File exposing (..)
import Css.Reset


port files : CssFileStructure -> Cmd msg


styles : List Stylesheet
styles =
    [ Css.Reset.css
    , AppCss.css
    ]


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "styles.css", Css.File.compile styles ) ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
