module Page.App exposing (..)

import Canvas
import Html exposing (..)
import Html.Attributes exposing (..)
import Phoenix
import Phoenix.Channel as Channel
import Phoenix.Socket as Socket


-- MODEL


type alias Model =
    { topic : String
    }


init : String -> ( Model, Cmd Msg )
init topic =
    ( Model topic, Cmd.none )



-- UPDATE


type Msg
    = None


type alias ExtMsg =
    ()


update : Msg -> Model -> ( Model, Cmd Msg, Maybe ExtMsg )
update msg model =
    case msg of
        None ->
            ( model, Cmd.none, Nothing )



-- VIEW


view : Model -> Html Msg
view model =
    Canvas.initialize (Canvas.Size 800 600)
        |> Canvas.toHtml [ class "ba db mt5 center" ]



-- SUBSCRIPTIONS


socket : Socket.Socket Msg
socket =
    Socket.init "ws://localhost:4000/socket/websocket"


topic : Model -> String
topic model =
    "canvas:" ++ model.topic


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        channel =
            Channel.init (topic model)
    in
        Phoenix.connect socket [ channel ]
