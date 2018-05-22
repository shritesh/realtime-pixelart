module Page.App exposing (..)

import Canvas exposing (Size, Style(Color), DrawOp(..))
import Color exposing (Color)
import ColorPicker
import Dict exposing (Dict)
import ElementRelativeMouseEvents as MouseEvents exposing (Point)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onMouseLeave)
import Json.Decode as Decode
import Json.Encode as Encode
import Phoenix
import Phoenix.Channel as Channel
import Phoenix.Push as Push
import Phoenix.Socket as Socket


-- MODEL


type alias Data =
    Dict ( Int, Int ) Color


type alias Model =
    { topic : String
    , data : Data
    , colorPicker : ColorPicker.State
    , color : Color
    , hoverPoint : Maybe ( Int, Int )
    }


init : String -> ( Model, Cmd Msg )
init topic =
    ( Model topic initData ColorPicker.empty Color.black Nothing, Cmd.none )


initData : Data
initData =
    Dict.empty



-- UPDATE


type Msg
    = ColorPickerMsg ColorPicker.Msg
    | MouseClick Point
    | MouseLeave
    | MouseMove Point
    | PixelMsg Decode.Value


type alias ExtMsg =
    ()


update : Msg -> Model -> ( Model, Cmd Msg, Maybe ExtMsg )
update msg model =
    case msg of
        ColorPickerMsg colorPickerMsg ->
            let
                ( subModel, color ) =
                    ColorPicker.update colorPickerMsg model.color model.colorPicker
            in
                ( { model | colorPicker = subModel, color = color |> Maybe.withDefault model.color }, Cmd.none, Nothing )

        MouseClick point ->
            ( model, pushPixel ( floor (point.x / 8), floor (point.y / 8) ) model, Nothing )

        MouseMove point ->
            ( { model | hoverPoint = Just ( floor (point.x / 8), floor (point.y / 8) ) }, Cmd.none, Nothing )

        MouseLeave ->
            ( { model | hoverPoint = Nothing }, Cmd.none, Nothing )

        PixelMsg value ->
            case Decode.decodeValue pixelDecoder value of
                Ok { x, y, r, g, b } ->
                    ( { model | data = Dict.insert ( x, y ) (Color.rgb r g b) model.data }, Cmd.none, Nothing )

                Err err ->
                    ( model, Cmd.none, Nothing )


pushPixel : ( Int, Int ) -> Model -> Cmd Msg
pushPixel ( x, y ) model =
    let
        rgb =
            Color.toRgb model.color

        payload =
            Encode.object
                [ ( "coordinate"
                  , Encode.list
                        [ Encode.int x
                        , Encode.int y
                        ]
                  )
                , ( "color"
                  , Encode.list
                        [ Encode.int rgb.red
                        , Encode.int rgb.green
                        , Encode.int rgb.blue
                        ]
                  )
                ]

        message =
            Push.init (topic model) "pixel"
                |> Push.withPayload payload
    in
        Phoenix.push "ws://localhost:4000/socket/websocket" message


type alias DecodedPixel =
    { x : Int
    , y : Int
    , r : Int
    , g : Int
    , b : Int
    }


pixelDecoder : Decode.Decoder DecodedPixel
pixelDecoder =
    Decode.map5 DecodedPixel
        (Decode.field "coordinate" (Decode.index 0 Decode.int))
        (Decode.field "coordinate" (Decode.index 1 Decode.int))
        (Decode.field "color" (Decode.index 0 Decode.int))
        (Decode.field "color" (Decode.index 1 Decode.int))
        (Decode.field "color" (Decode.index 2 Decode.int))



-- VIEW


view : Model -> Html Msg
view model =
    main_ []
        [ div [ class "tc mt3" ]
            [ ColorPicker.view model.color model.colorPicker
                |> Html.map ColorPickerMsg
            ]
        , Canvas.initialize (Size 800 600)
            |> Canvas.draw (drawing model)
            |> Canvas.toHtml [ class "ba db mt3 center", MouseEvents.onClick MouseClick, MouseEvents.onMouseMove MouseMove, onMouseLeave MouseLeave, style [ ( "cursor", "none" ) ] ]
        ]


drawing : Model -> DrawOp
drawing model =
    let
        process : ( Int, Int ) -> Color -> List DrawOp -> List DrawOp
        process ( x, y ) color list =
            List.append list
                [ FillStyle (Color color)
                , FillRect (Point (toFloat x * 8) (toFloat y * 8)) (Size 8 8)
                ]

        hoverPixel list =
            case model.hoverPoint of
                Just ( x, y ) ->
                    process ( x, y ) model.color list

                Nothing ->
                    list
    in
        Dict.foldl process [] model.data
            |> hoverPixel
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
                |> Channel.on "pixel" PixelMsg
    in
        Phoenix.connect socket [ channel ]
