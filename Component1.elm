module Component1 exposing (Model, Msg(Notify, Local), init, update, view)

import Html as H exposing (Html, Attribute)
import Html.Attributes as HA
import Html.Events as HE


type alias Model =
    Int


init : Model
init =
    0


type LocalMsg
    = Increment


type Msg
    = Notify
    | Local LocalMsg


update : LocalMsg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            (model + 1) ! []


view : Model -> Html Msg
view model =
    H.div []
        [ H.button [ HE.onClick (Local Increment) ] [ H.text "+" ]
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
