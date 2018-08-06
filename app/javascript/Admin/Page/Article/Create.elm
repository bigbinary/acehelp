module Page.Article.Create exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Data.Article exposing (..)
import Admin.Request.Article exposing (..)
import Admin.Request.Category exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Admin.Data.Category exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import Helpers exposing (..)
import Page.Article.Common exposing (..)
import GraphQL.Client.Http as GQLClient


-- Model


type alias Model =
    { title : Field String String
    , desc : Field String String
    , articleId : Maybe ArticleId
    , categories : List Category
    , categoryId : Field String String
    , error : Maybe String
    }


initModel : Model
initModel =
    { title = Field (validateEmpty "Title") ""
    , desc = Field (validateEmpty "Article Content") ""
    , articleId = Nothing
    , categories = []
    , categoryId = Field (validateEmpty "Category Id") ""
    , error = Nothing
    }


init : ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Category)) )
init =
    ( initModel
    , requestCategories
    )



-- Update


type Msg
    = TitleInput String
    | DescInput String
    | SaveArticle
    | SaveArticleResponse (Result GQLClient.Error Article)
    | CategoriesLoaded (Result GQLClient.Error (List Category))
    | CategorySelected String


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
    case msg of
        TitleInput title ->
            ( { model | title = Field.update model.title title }, Cmd.none )

        DescInput desc ->
            ( { model | desc = Field.update model.desc desc }, Cmd.none )

        SaveArticle ->
            let
                fields =
                    [ model.title, model.desc ]

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
                    save model nodeEnv organizationKey
                else
                    ( { model | error = Just errors }, Cmd.none )

        SaveArticleResponse (Ok id) ->
            ( { model
                | title = Field.update model.title ""
                , desc = Field.update model.desc ""
              }
            , Cmd.none
            )

        SaveArticleResponse (Err error) ->
            ( { model | error = Just (toString error) }, Cmd.none )

        CategoriesLoaded (Ok categories) ->
            ( { model | categories = categories }, Cmd.none )

        CategoriesLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        CategorySelected categoryId ->
            ( { model | categoryId = Field.update model.categoryId categoryId }, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div []
        [ errorView model.error
        , div [ class "row article-block" ]
            [ div [ class "col-md-8 article-title-content-block" ]
                [ div
                    [ class "row article-title" ]
                    [ input
                        [ type_ "text"
                        , class "form-control"
                        , placeholder "Title"
                        , onInput TitleInput
                        ]
                        []
                    ]
                , div
                    [ class "row article-content" ]
                    [ node "trix-editor"
                        [ placeholder "Article content goes here.."
                        , onInput DescInput
                        ]
                        []
                    ]
                ]
            , div [ class "col-sm article-meta-data-block" ]
                [ categoryListDropdown model.categories (Field.value model.categoryId) (CategorySelected)

                -- , articleUrls model.
                , button [ id "create-article", type_ "button", class "btn btn-success", onClick SaveArticle ] [ text "Create Article" ]
                ]
            ]
        ]


save : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
save model nodeEnv organizationKey =
    let
        cmd =
            Task.attempt SaveArticleResponse
                (Reader.run
                    (requestCreateArticle
                        (articleInputs
                            { title = model.title, desc = model.desc, categoryId = model.categoryId }
                        )
                    )
                    ( nodeEnv, organizationKey )
                )
    in
        ( model, cmd )


articleInputs : { title : Field String String, desc : Field String String, categoryId : Field String String } -> CreateArticleInputs
articleInputs { title, desc, categoryId } =
    { title = Field.value title
    , desc = Field.value desc
    , categoryId = Just <| Field.value categoryId
    }
