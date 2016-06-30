module Component2 exposing (Model, Msg(Notify), init, update, view)

import Html as H exposing (Html, Attribute)
import Html.Attributes as HA
import Html.Events as HE


type alias Model =
    Int


init : Model
init =
    0


type Msg
    = Notify
    | Increment


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            (model + 1) ! []

        Notify ->
            model ! []


view : Model -> Html Msg
view model =
    H.div []
        [ H.button [ HE.onClick Increment ] [ H.text "+" ]
        , H.div [ countStyle ] [ H.text (toString model) ]
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
