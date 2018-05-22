module Main exposing (..)

import Html exposing (Html, text)
import Page.App as App
import Page.Welcome as Welcome


main : Program String Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type Page
    = App App.Model
    | Welcome Welcome.Model


type alias Model =
    { endpoint : String
    , page : Page
    }


init : String -> ( Model, Cmd Msg )
init endpoint =
    let
        ( subModel, subCmd ) =
            Welcome.init
    in
        ( Model endpoint (Welcome subModel), Cmd.map WelcomeMsg subCmd )



-- UPDATE


type Msg
    = AppMsg App.Msg
    | WelcomeMsg Welcome.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( AppMsg appMsg, App appModel ) ->
            let
                ( subModel, subCmd, extMsg ) =
                    App.update appMsg appModel
            in
                case extMsg of
                    _ ->
                        ( { model | page = App subModel }, Cmd.map AppMsg subCmd )

        ( WelcomeMsg welcomeMsg, Welcome welcomeModel ) ->
            let
                ( subModel, subCmd, extMsg ) =
                    Welcome.update welcomeMsg welcomeModel
            in
                case extMsg of
                    Just (Welcome.Topic topic) ->
                        let
                            ( subModel, subCmd ) =
                                App.init model.endpoint topic
                        in
                            ( { model | page = App subModel }, Cmd.map AppMsg subCmd )

                    Nothing ->
                        ( { model | page = Welcome subModel }, Cmd.map WelcomeMsg subCmd )

        ( _, _ ) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model.page of
        App appModel ->
            App.view appModel |> Html.map AppMsg

        Welcome welcomeModel ->
            Welcome.view welcomeModel |> Html.map WelcomeMsg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        App appModel ->
            App.subscriptions appModel |> Sub.map AppMsg

        Welcome welcomeModel ->
            Welcome.subscriptions welcomeModel |> Sub.map WelcomeMsg
