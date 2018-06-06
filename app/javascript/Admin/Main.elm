module Main exposing (..)

import Html exposing (Html, div, text)
import Navigation


-- MODEL


type alias Flags =
    { node_env : String
    }


type alias Model =
    String


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    ( "Howdy!", Cmd.none )



-- MSG


type Msg
    = Noop
    | UrlChange Navigation.Location



-- VIEW


view : Model -> Html Msg
view model =
    div [] [ text model ]



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        UrlChange location ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main : Program Flags Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
