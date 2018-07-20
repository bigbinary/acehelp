module Page.Url.Create exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Request.UrlRequest exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Data.CommonData exposing (Error)
import Data.UrlData exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient


-- MODEL


type alias Model =
    { error : Error
    , id : String
    , url : String
    , urlError : Error
    , urlTitle : String
    , urlTitleError : Error
    }


initModel : Model
initModel =
    { error = Nothing
    , id = "0"
    , url = ""
    , urlError = Nothing
    , urlTitle = ""
    , urlTitleError = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( initModel
    , Cmd.none
    )



-- UPDATE


type Msg
    = UrlInput String
    | TitleInput String
    | SaveUrl
    | SaveUrlResponse (Result GQLClient.Error UrlData)


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
    case msg of
        UrlInput url ->
            ( { model | url = url }, Cmd.none )

        TitleInput title ->
            ( { model | urlTitle = title }, Cmd.none )

        SaveUrl ->
            let
                updatedModel =
                    validate model
            in
                if isValid updatedModel then
                    save updatedModel nodeEnv
                else
                    ( updatedModel, Cmd.none )

        SaveUrlResponse (Ok id) ->
            ( { model
                | url = ""
                , urlError = Nothing
                , urlTitle = ""
                , urlTitleError = Nothing
                , error = Nothing
              }
            , Cmd.none
            )

        SaveUrlResponse (Err error) ->
            ( { model | error = Just (toString error) }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Html.form [ onSubmit SaveUrl ]
            [ div []
                [ label [] [ text "URL: " ]
                , input
                    [ type_ "text"
                    , placeholder "Url..."
                    , value model.url
                    , onInput UrlInput
                    ]
                    []
                ]
            , div []
                [ label [] [ text "URL Title: " ]
                , input
                    [ type_ "text"
                    , placeholder "Title..."
                    , value model.urlTitle
                    , onInput TitleInput
                    ]
                    []
                ]
            , button [ type_ "submit", class "button primary" ] [ text "Save URL" ]
            ]
        ]


validate : Model -> Model
validate model =
    model
        |> validateUrl
        |> validateUrlTitle


validateUrl : Model -> Model
validateUrl model =
    if String.isEmpty model.url then
        { model
            | urlError = Just "Url is required"
        }
    else
        { model
            | urlError = Nothing
        }


validateUrlTitle : Model -> Model
validateUrlTitle model =
    if String.isEmpty model.urlTitle then
        { model
            | urlTitleError = Just "Title required"
        }
    else
        { model
            | urlTitleError = Nothing
        }


isValid : Model -> Bool
isValid model =
    model.urlError
        == Nothing
        && model.urlTitleError
        == Nothing


save : Model -> NodeEnv -> ( Model, Cmd Msg )
save model nodeEnv =
    let
        cmd =
            Task.attempt SaveUrlResponse (Reader.run (createUrl) ( nodeEnv, { url = model.url } ))
    in
        ( model, cmd )
