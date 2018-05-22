module Page.Welcome exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- MODEL


type alias Model =
    { topic : String
    }


init : ( Model, Cmd Msg )
init =
    ( Model "", Cmd.none )



-- UPDATE


type Msg
    = ClickJoin
    | ChangeTopic String


type ExtMsg
    = Topic String


update : Msg -> Model -> ( Model, Cmd Msg, Maybe ExtMsg )
update msg model =
    case msg of
        ClickJoin ->
            if not (String.isEmpty model.topic) then
                ( model, Cmd.none, Just (Topic model.topic) )
            else
                ( model, Cmd.none, Nothing )

        ChangeTopic topic ->
            ( { model | topic = topic }, Cmd.none, Nothing )



-- VIEW


view : Model -> Html Msg
view model =
    Html.form [ class "measure center pa5 sans-serif", onSubmit ClickJoin ]
        [ input [ onInput ChangeTopic, value model.topic, placeholder "Topic", class "pa2 input-reset ba b--black w-80" ] []
        , input [ type_ "submit", value "Join", class "pa2 button-reset ba b--black w-auto" ] []
        ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
