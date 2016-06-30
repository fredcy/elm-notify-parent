module Main exposing (main)

import Html
import Html.App
import Html.Attributes as HA
import Component1


type alias Model =
    { component1 : Component1.Model
    , notified1 : Bool
    }


type Msg
    = Component1Msg Component1.Msg


main : Program Never
main =
    Html.App.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


init : ( Model, Cmd Msg )
init =
    ( Model Component1.init False, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg |> Debug.log "msg" of
        Component1Msg c1Msg ->
            case c1Msg of
                Component1.Local localMsg ->
                    let
                        ( c1model, c1cmd ) =
                            Component1.update localMsg model.component1
                    in
                        { model | component1 = c1model } ! [ Cmd.map Component1Msg c1cmd ]

                Component1.Notify ->
                    { model | notified1 = not model.notified1 } ! []


view : Model -> Html.Html Msg
view model =
    Html.div [
         HA.class (if model.notified1 then "notified" else "")
        ]
        [ Component1.view model.component1 |> Html.App.map Component1Msg
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
