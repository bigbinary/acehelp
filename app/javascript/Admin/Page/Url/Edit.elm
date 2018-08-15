module Page.Url.Edit exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Request.Url exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Admin.Data.Url exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Field exposing (..)
import Helpers exposing (..)
import Field.ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient
import Page.Helpers exposing (..)


-- MODEL


type alias Model =
    { error : Maybe String
    , success : Maybe String
    , url : Field String String
    , urlId : UrlId
    }


initModel : UrlId -> Model
initModel urlId =
    { error = Nothing
    , success = Nothing
    , url = Field (validateEmpty "Url") ""
    , urlId = urlId
    }


init : UrlId -> ( Model, List (PageCmd Msg) )
init urlId =
    ( initModel urlId
    , [ Reader.map (Task.attempt UrlLoaded) (requestUrlById urlId) ]
    )



-- UPDATE


type Msg
    = UrlInput String
    | UpdateUrl
    | UpdateUrlResponse (Result GQLClient.Error UrlData)
    | UrlLoaded (Result GQLClient.Error UrlData)


update : Msg -> Model -> ( Model, List (PageCmd Msg) )
update msg model =
    case msg of
        UrlInput url ->
            ( { model | url = Field.update model.url url }, [] )

        UpdateUrl ->
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
                if isAllValid fields then
                    save model
                else
                    ( { model | error = Just errors }, [] )

        UpdateUrlResponse (Ok id) ->
            ( { model
                | url = Field.update model.url id.url
                , success = Just "Url Updated Successfully."
              }
            , []
            )

        UpdateUrlResponse (Err error) ->
            ( { model | error = Just (toString error) }, [] )

        UrlLoaded (Ok url) ->
            ( { model
                | url = Field.update model.url url.url
                , urlId = url.id
              }
            , []
            )

        UrlLoaded (Err err) ->
            ( { model | error = Just "There was an error loading up the url" }, [] )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Html.form [ onSubmit UpdateUrl ]
            [ div []
                [ Maybe.withDefault (text "") <|
                    Maybe.map
                        (\err ->
                            div [ class "alert alert-danger alert-dismissible fade show", attribute "role" "alert" ]
                                [ text <| "Error: " ++ err
                                ]
                        )
                        model.error
                ]
            , div []
                [ Maybe.withDefault (text "") <|
                    Maybe.map
                        (\message ->
                            div [ class "alert alert-success alert-dismissible fade show", attribute "role" "alert" ]
                                [ text <| message
                                ]
                        )
                        model.success
                ]
            , div []
                [ label [] [ text "URL: " ]
                , input
                    [ Html.Attributes.value <| Field.value model.url
                    , type_ "text"
                    , placeholder "Url..."
                    , onInput UrlInput
                    ]
                    []
                ]
            , button [ type_ "submit", class "button primary" ] [ text "Update URL" ]
            ]
        ]


urlInputs : Model -> UrlData
urlInputs { url, urlId } =
    { url = Field.value url
    , id = urlId
    }


save : Model -> ( Model, List (PageCmd Msg) )
save model =
    let
        cmd =
            (Reader.map (Task.attempt UpdateUrlResponse) (updateUrl <| urlInputs model))
    in
        ( model, [ cmd ] )
