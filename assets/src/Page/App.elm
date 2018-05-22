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
import Navigation exposing (Location)
import Phoenix
import Phoenix.Channel as Channel
import Phoenix.Push as Push
import Phoenix.Socket as Socket


-- MODEL


type alias Data =
    Dict ( Int, Int ) Color


type alias Model =
    { location : Location
    , data : Data
    , colorPicker : ColorPicker.State
    , color : Color
    , hoverPoint : Maybe ( Int, Int )
    }


init : Location -> ( Model, Cmd Msg )
init location =
    ( Model location Dict.empty ColorPicker.empty Color.black Nothing, Cmd.none )



-- UPDATE


type Msg
    = ColorPickerMsg ColorPicker.Msg
    | JoinMsg Decode.Value
    | MouseClick Point
    | MouseLeave
    | MouseMove Point
    | PixelMsg Decode.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ColorPickerMsg colorPickerMsg ->
            let
                ( subModel, color ) =
                    ColorPicker.update colorPickerMsg model.color model.colorPicker
            in
                ( { model | colorPicker = subModel, color = color |> Maybe.withDefault model.color }, Cmd.none )

        JoinMsg value ->
            case Decode.decodeValue canvasDecoder value of
                Ok decodedPixels ->
                    ( { model | data = List.foldl insertPixel model.data decodedPixels }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        MouseClick point ->
            ( model, pushPixel ( floor (point.x / 8), floor (point.y / 8) ) model )

        MouseMove point ->
            ( { model | hoverPoint = Just ( floor (point.x / 8), floor (point.y / 8) ) }, Cmd.none )

        MouseLeave ->
            ( { model | hoverPoint = Nothing }, Cmd.none )

        PixelMsg value ->
            case Decode.decodeValue pixelDecoder value of
                Ok decodedPixel ->
                    ( { model | data = insertPixel decodedPixel model.data }, Cmd.none )

                Err err ->
                    ( model, Cmd.none )


insertPixel : DecodedPixel -> Data -> Data
insertPixel { x, y, r, g, b } data =
    Dict.insert ( x, y ) (Color.rgb r g b) data


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
        Phoenix.push (endpoint model) message


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


canvasDecoder : Decode.Decoder (List DecodedPixel)
canvasDecoder =
    Decode.field "canvas" (Decode.list pixelDecoder)



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


endpoint : Model -> String
endpoint model =
    let
        protocol =
            case model.location.protocol of
                "https:" ->
                    "wss://"

                _ ->
                    "ws://"
    in
        protocol ++ model.location.host ++ "/socket/websocket"


socket : Model -> Socket.Socket Msg
socket model =
    Socket.init (endpoint model)


topic : Model -> String
topic model =
    "canvas:" ++ (String.dropLeft 1 model.location.pathname)


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        channel =
            Channel.init (topic model)
                |> Channel.onJoin JoinMsg
                |> Channel.on "pixel" PixelMsg
    in
        Phoenix.connect (socket model) [ channel ]
