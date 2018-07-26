module Page.Url.Edit exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Request.UrlRequest exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Data.UrlData exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Field exposing (..)
import Helpers exposing (..)
import Field.ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient


-- MODEL


type alias Model =
    { error : Maybe String
    , url : Field String String
    , id : UrlId
    }


initModel : UrlId -> Model
initModel urlId =
    { error = Nothing
    , url = Field (validateEmpty "Url") ""
    , id = urlId
    }


init : UrlId -> ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error UrlData) )
init urlId =
    ( initModel urlId
    , requestUrlById urlId
    )



-- UPDATE


type Msg
    = UrlInput String
    | SaveUrl
    | SaveUrlResponse (Result GQLClient.Error UrlData)
    | UrlLoaded (Result GQLClient.Error UrlData)


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
    case msg of
        UrlInput url ->
            ( { model | url = Field.update model.url url }, Cmd.none )

        SaveUrl ->
            let
                fields =
                    [ model.url ]

                errors =
                    validateAll fields
                        |> filterFailures
                        |> List.map
                            (\result ->
                                case result of
                                    Failed err ->
                                        err

                                    Passed _ ->
                                        "Unknown Error"
                            )
                        |> String.join ", "
            in
                if 1 == 1 then
                    save model nodeEnv organizationKey
                else
                    ( { model | error = Just <| Debug.log "" errors }, Cmd.none )

        SaveUrlResponse (Ok id) ->
            ( { model
                | url = Field.update model.url ""
              }
            , Cmd.none
            )

        SaveUrlResponse (Err error) ->
            ( { model | error = Just (toString error) }, Cmd.none )

        UrlLoaded (Ok url) ->
            ( { model
                | url = Field.update model.url url.url
              }
            , Cmd.none
            )

        UrlLoaded (Err err) ->
            ( { model | error = Just "There was an error loading up the url" }, Cmd.none )



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
                    , onInput UrlInput
                    ]
                    []
                ]
            , button [ type_ "submit", class "button primary" ] [ text "Save URL" ]
            ]
        ]


urlInputs : Model -> CreateUrlInput
urlInputs { url } =
    { url = Field.value url
    }


save : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
save model nodeEnv organizationKey =
    let
        cmd =
            Task.attempt SaveUrlResponse (Reader.run (createUrl) ( nodeEnv, (urlInputs model) ))
    in
        ( model, cmd )
