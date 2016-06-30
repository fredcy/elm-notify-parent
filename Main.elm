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
import Component1
import Component2
import Component3
import Component4


type alias Model =
    { component1 : Component1.Model
    , notified1 : Bool
    , component2 : Component2.Model
    , notified2 : Bool
    , component3 : Component3.Model
    , notified3 : Bool
    , component4 : Component4.Model
    , notified4 : Bool
    }


type Msg
    = Component1Msg Component1.Msg
    | Component2Msg Component2.Msg
    | Component3Msg Component3.Msg
    | Component4Msg Component4.Msg


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
    ( Model Component1.init False Component2.init False Component3.init False Component4.init False
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg |> Debug.log "msg" of
        -- Inspect component messages and act on Notify. The component's
        -- messages are defined with a nested Local type for messages handled
        -- only by the component.
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

        -- Inspect component message and act on Notify. Unlike just above, all
        -- the component's messages are in a single union type. Only Notify is
        -- exposed. We don't pass Notify back down to the component (but its
        -- update function will have to account for it anyway).
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

        -- Component uses third element of return tuple from update to indicate
        -- that it is notifying.
        Component3Msg c3Msg ->
            let
                ( c3model, c3cmd, notified ) =
                    Component3.update c3Msg model.component3

                notified' =
                    notified `xor` model.notified3
            in
                ( { model | component3 = c3model, notified3 = notified' }, Cmd.map Component3Msg c3cmd )

        -- Component exposes a `notifying` value that indicates whether it is
        -- notifying. We therefore need to update the component to clear the
        -- notification from the component itself once we've acted on it.
        Component4Msg c4Msg ->
            let
                ( c4model, c4cmd ) =
                    Component4.update c4Msg model.component4

                notified' =
                    Component4.notifying c4model `xor` model.notified4

                ( c4model', c4cmd' ) =
                    if Component4.notifying c4model then
                        Component4.update Component4.ClearNotify c4model
                    else
                        ( c4model, Cmd.none )
            in
                ( { model | component4 = c4model', notified4 = notified' }
                , Cmd.batch [ c4cmd, c4cmd' ] |> Cmd.map Component4Msg
                )


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ Html.div [ HA.classList [ ( "notified", model.notified1 ) ] ]
            [ Component1.view model.component1 |> Html.App.map Component1Msg ]
        , Html.div [ HA.classList [ ( "notified", model.notified2 ) ] ]
            [ Component2.view model.component2 |> Html.App.map Component2Msg ]
        , Html.div [ HA.classList [ ( "notified", model.notified3 ) ] ]
            [ Component3.view model.component3 |> Html.App.map Component3Msg ]
        , Html.div [ HA.classList [ ( "notified", model.notified4 ) ] ]
            [ Component4.view model.component4 |> Html.App.map Component4Msg ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
