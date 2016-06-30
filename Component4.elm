module Component4 exposing (Model, Msg(ClearNotify), init, update, view, notifying)

import Html as H exposing (Html, Attribute)
import Html.Attributes as HA
import Html.Events as HE


type alias Model =
    { count : Int
    , notify : Bool
    }


init : Model
init =
    Model 0 False


type Msg
    = Notify
    | Increment
    | ClearNotify


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            { model | count = model.count + 1, notify = False } ! []

        Notify ->
            { model | notify = True } ! []

        ClearNotify ->
            { model | notify = False } ! []


notifying : Model -> Bool
notifying model =
    model.notify


view : Model -> Html Msg
view model =
    H.div []
        [ H.button [ HE.onClick Increment ] [ H.text "+" ]
        , H.div [ countStyle ] [ H.text (toString model.count) ]
        , H.button [ HE.onClick Notify ] [ H.text "Notify" ]
        ]


countStyle : Attribute Msg
countStyle =
    HA.style
        [ ( "font-size", "20px" )
        , ( "font-family", "monospace" )
        , ( "display", "inline-block" )
        , ( "width", "50px" )
        , ( "text-align", "center" )
        ]
