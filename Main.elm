module Main exposing (main)

import Html
import Html.App
import Component1


type alias Model =
    { component1 : Component1.Model
    }


type Msg
    = NoOp


main =
    Html.App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( Model Component1.init, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Component1.view model.component1
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
