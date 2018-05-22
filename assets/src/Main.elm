module Main exposing (..)

import Html exposing (Html, text)
import Navigation exposing (Location)
import Page.App as App
import Page.Welcome as Welcome


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type Model
    = App App.Model
    | Welcome Welcome.Model


init : Location -> ( Model, Cmd Msg )
init location =
    case location.pathname of
        "/" ->
            initWelcome

        _ ->
            initApp location


initWelcome : ( Model, Cmd Msg )
initWelcome =
    let
        ( subModel, subCmd ) =
            Welcome.init
    in
        ( Welcome subModel, Cmd.map WelcomeMsg subCmd )


initApp : Location -> ( Model, Cmd Msg )
initApp location =
    let
        ( subModel, subCmd ) =
            App.init location
    in
        ( App subModel, Cmd.map AppMsg subCmd )



-- UPDATE


type Msg
    = AppMsg App.Msg
    | WelcomeMsg Welcome.Msg
    | UrlChange Location


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( UrlChange location, _ ) ->
            init location

        ( AppMsg appMsg, App appModel ) ->
            let
                ( subModel, subCmd ) =
                    App.update appMsg appModel
            in
                ( App subModel, Cmd.map AppMsg subCmd )

        ( WelcomeMsg welcomeMsg, Welcome welcomeModel ) ->
            let
                ( subModel, subCmd ) =
                    Welcome.update welcomeMsg welcomeModel
            in
                ( Welcome subModel, Cmd.map WelcomeMsg subCmd )

        ( _, _ ) ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    case model of
        App appModel ->
            App.view appModel |> Html.map AppMsg

        Welcome welcomeModel ->
            Welcome.view welcomeModel |> Html.map WelcomeMsg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        App appModel ->
            App.subscriptions appModel |> Sub.map AppMsg

        Welcome welcomeModel ->
            Welcome.subscriptions welcomeModel |> Sub.map WelcomeMsg
