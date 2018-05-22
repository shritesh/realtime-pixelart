module Page.App exposing (..)

import Canvas exposing (Size, Style(Color), DrawOp(..))
import Dict exposing (Dict)
import Color exposing (Color)
import ElementRelativeMouseEvents as MouseEvents exposing (Point)
import Html exposing (..)
import Html.Attributes exposing (..)
import Phoenix
import Phoenix.Channel as Channel
import Phoenix.Socket as Socket


-- MODEL


type alias Data =
    Dict ( Int, Int ) Color


type alias Model =
    { topic : String
    , data : Data
    }


init : String -> ( Model, Cmd Msg )
init topic =
    ( Model topic initData, Cmd.none )


initData : Data
initData =
    Dict.empty



-- UPDATE


type Msg
    = MouseClick Point


type alias ExtMsg =
    ()


update : Msg -> Model -> ( Model, Cmd Msg, Maybe ExtMsg )
update msg model =
    case msg of
        MouseClick point ->
            ( { model | data = Dict.insert ( floor (point.x / 8), floor (point.y / 8) ) Color.black model.data }, Cmd.none, Nothing )



-- VIEW


view : Model -> Html Msg
view model =
    Canvas.initialize (Size 800 600)
        |> Canvas.draw (drawing model.data)
        |> Canvas.toHtml [ class "ba db mt5 center", MouseEvents.onClick MouseClick ]


drawing : Data -> DrawOp
drawing data =
    let
        process : ( Int, Int ) -> Color -> List DrawOp -> List DrawOp
        process ( x, y ) color list =
            List.append list
                [ FillStyle (Color color)
                , FillRect (Point (toFloat x * 8) (toFloat y * 8)) (Size 8 8)
                ]
    in
        Dict.foldl process [] data
            |> Canvas.batch



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
