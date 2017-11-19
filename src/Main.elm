module Main exposing (..)

import Html exposing (Html, h1, text)


main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Model = Int

init : (Model, Cmd Msg)
init =
  (0, Cmd.none)


-- UPDATE

type Msg = Foo

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = 
  (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- VIEW

view : Model -> Html Msg
view model =
  h1 [] [ text "Gfrör.li – Wassertemperaturen Schweiz" ]
