module Main exposing (main)

{-| Try several different approaches to having a component notify its parent of
an event. This Main module is the parent and the several Component* modules show
the several variations.

Each component implements a counter that can be incremented and displayed, with
the parent providing only the usual opaque TEA wiring. Each component also
implements a "notify" button that is to report a Notify event to the
parent. This notification is where we try several different approached. When it
is notified (through some varying means) we have the parent just toggle a
'notified*' field corresponding the component and have the parent display the
component view differently based on that field. (A more likely use would be
something like a "delete me" button in the component which notifies the parent
to remove the component from the parent's model.)
-}

import Html
import Html.App
import Html.Attributes as HA
import Component1 as C1
import Component2 as C2
import Component3 as C3
import Component4 as C4


type alias Model =
    { component1 : C1.Model
    , notified1 : Bool
    , component2 : C2.Model
    , notified2 : Bool
    , component3 : C3.Model
    , notified3 : Bool
    , component4 : C4.Model
    , notified4 : Bool
    }


type Msg
    = C1Msg C1.Msg
    | C2Msg C2.Msg
    | C3Msg C3.Msg
    | C4Msg C4.Msg


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
    ( Model C1.init False C2.init False C3.init False C4.init False
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg |> Debug.log "msg" of
        -- Inspect component messages and act on Notify. The component's
        -- messages are defined with a nested Local type for messages handled
        -- by the component.
        C1Msg c1Msg ->
            case c1Msg of
                C1.Notify ->
                    { model | notified1 = not model.notified1 } ! []

                C1.Local localMsg ->
                    let
                        ( c1model, c1cmd ) =
                            C1.update localMsg model.component1
                    in
                        { model | component1 = c1model } ! [ Cmd.map C1Msg c1cmd ]

        -- Inspect component message and act on Notify. Unlike just above, all
        -- the component's messages are in a single union type. Only Notify is
        -- exposed. We don't pass Notify back down to the component (but its
        -- update function will have to account for it anyway).
        C2Msg c2Msg ->
            case c2Msg of
                C2.Notify ->
                    { model | notified2 = not model.notified2 } ! []

                _ ->
                    let
                        ( c2model, c2cmd ) =
                            C2.update c2Msg model.component2
                    in
                        { model | component2 = c2model } ! [ Cmd.map C2Msg c2cmd ]

        -- Component uses third element of return tuple from update to pass back 
        -- notification.
        C3Msg c3Msg ->
            let
                ( c3model, c3cmd, notification ) =
                    C3.update c3Msg model.component3

                notified' =
                    case notification of
                        Just C3.Notifying ->
                            not model.notified3
                        Nothing ->
                            model.notified3
            in
                ( { model | component3 = c3model, notified3 = notified' }, Cmd.map C3Msg c3cmd )

        -- Component exposes a `notifying` value that indicates whether it is
        -- notifying. We therefore need to update the component to clear the
        -- notification from the component itself once we've acted on it.
        C4Msg c4Msg ->
            let
                ( c4model, c4cmd ) =
                    C4.update c4Msg model.component4

                notified' =
                    C4.notifying c4model `xor` model.notified4

                ( c4model', c4cmd' ) =
                    if C4.notifying c4model then
                        C4.update C4.ClearNotify c4model
                    else
                        ( c4model, Cmd.none )
            in
                ( { model | component4 = c4model', notified4 = notified' }
                , Cmd.batch [ c4cmd, c4cmd' ] |> Cmd.map C4Msg
                )


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.div [ HA.classList [ ( "notified", model.notified1 ) ] ]
            [ C1.view model.component1 |> Html.App.map C1Msg ]
        , Html.div [ HA.classList [ ( "notified", model.notified2 ) ] ]
            [ C2.view model.component2 |> Html.App.map C2Msg ]
        , Html.div [ HA.classList [ ( "notified", model.notified3 ) ] ]
            [ C3.view model.component3 |> Html.App.map C3Msg ]
        , Html.div [ HA.classList [ ( "notified", model.notified4 ) ] ]
            [ C4.view model.component4 |> Html.App.map C4Msg ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
