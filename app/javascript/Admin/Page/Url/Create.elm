module Page.Url.Create exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Encode as JE
import Request.UrlRequest exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Data.CommonData exposing (Error)


-- MODEL


type alias Model =
    { error : Error
    , id : Int
    , url : String
    , urlError : Error
    , urlTitle : String
    , urlTitleError : Error
    }


initModel : Model
initModel =
    { error = Nothing
    , id = 0
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
    | SaveUrlResponse (Result Http.Error String)


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
                    save updatedModel nodeEnv organizationKey
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
            let
                errorMessage =
                    case error of
                        Http.BadStatus response ->
                            response.body

                        _ ->
                            "Error while saving URL"
            in
                ( { model
                    | error = Just errorMessage
                  }
                , Cmd.none
                )



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


urlEncoder : Model -> JE.Value
urlEncoder { url } =
    JE.object
        [ ( "url"
          , JE.object
                [ ( "url", JE.string url )
                ]
          )
        ]


save : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
save model nodeEnv organizationKey =
    ( model, Http.send SaveUrlResponse (createUrl nodeEnv organizationKey (urlEncoder model)) )
