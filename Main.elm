module Main exposing (main)

import Html
import Html.App
import Html.Attributes as HA
import Component1
import Component2


type alias Model =
    { component1 : Component1.Model
    , notified1 : Bool
    , component2 : Component2.Model
    , notified2 : Bool
    }


type Msg
    = Component1Msg Component1.Msg
    | Component2Msg Component2.Msg


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
    ( Model Component1.init False Component2.init False
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg |> Debug.log "msg" of
        Component1Msg c1Msg ->
            case c1Msg of
                Component1.Notify ->
                    { model | notified1 = not model.notified1 } ! []

                Component1.Local localMsg ->
                    let
                        ( c1model, c1cmd ) =
                            Component1.update localMsg model.component1
                    in
                        { model | component1 = c1model } ! [ Cmd.map Component1Msg c1cmd ]

        Component2Msg c2Msg ->
            case c2Msg of
                Component2.Notify ->
                    { model | notified2 = not model.notified2 } ! []

                _ ->
                    let
                        ( c2model, c2cmd ) =
                            Component2.update c2Msg model.component2
                    in
                        { model | component2 = c2model } ! [ Cmd.map Component2Msg c2cmd ]


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.div [ HA.classList [ ( "notified", model.notified1 ) ] ]
            [ Component1.view model.component1 |> Html.App.map Component1Msg ]
        , Html.div [ HA.classList [ ( "notified", model.notified2 ) ] ]
            [ Component2.view model.component2 |> Html.App.map Component2Msg ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
