module Page.Article.Create exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Data.ArticleData exposing (..)
import Request.ArticleRequest exposing (..)
import Request.CategoryRequest exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Data.CategoryData exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import Helpers exposing (..)
import GraphQL.Client.Http as GQLClient


-- Model


type alias Model =
    { title : Field String String
    , desc : Field String String
    , keywords : Field String String
    , articleId : Maybe ArticleId
    , categories : List Category
    , categoryId : Field String String
    , error : Maybe String
    }


initModel : Model
initModel =
    { title = Field (validateEmpty "Title") ""
    , desc = Field (validateEmpty "Article Content") ""
    , keywords = Field (validateEmpty "Keywords") ""
    , articleId = Nothing
    , categories = []
    , categoryId =
        Field
            (\cId ->
                case cId of
                    "" ->
                        Failed "categpry Id cannot be empty"

                    "0" ->
                        Failed "Please select a categpryId"

                    _ ->
                        Passed cId
            )
            "0"
    , error = Nothing
    }


init : ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Category)) )
init =
    ( initModel
    , requestCategories
    )



-- Update


type Msg
    = NewArticle
    | ShowArticle ArticleId
    | TitleInput String
    | DescInput String
    | KeywordsInput String
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

        KeywordsInput keywords ->
            ( { model | keywords = Field.update model.keywords keywords }, Cmd.none )

        SaveArticle ->
            if isAllValid [ model.title, model.desc, model.keywords, model.categoryId ] then
                save model nodeEnv organizationKey
            else
                ( model, Cmd.none )

        SaveArticleResponse (Ok id) ->
            ( { model
                | title = Field.update model.title ""
                , desc = Field.update model.desc ""
                , keywords = Field.update model.keywords ""
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

        _ ->
            ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div [ class "row article-block" ]
        [ div [ class "col-md-8 article-title-content-block" ]
            [ div
                [ class "row article-title" ]
                [ input [ type_ "text", class "form-control", placeholder "Title" ] []
                ]
            , div
                [ class "row article-content" ]
                [ node "trix-editor" [ placeholder "Article content goes here.." ] []
                ]
            ]
        , div [ class "col-sm article-meta-data-block" ]
            [ categoryListDropdown model
            , articleUrls model
            , articleKeywords model
            , button [ id "create-article", type_ "button", class "btn btn-success" ] [ text "Create Article" ]
            ]
        ]


articleKeywords : Model -> Html Msg
articleKeywords model =
    div []
        [ h6 [] [ text "Keywords:" ]
        , input
            [ onInput KeywordsInput
            , Html.Attributes.value <| Field.value model.keywords
            , type_ "text"
            , class "form-control"
            , placeholder "Article keywords"
            ]
            []
        ]


articleUrls : Model -> Html Msg
articleUrls model =
    div []
        [ h6 [] [ text "Linked URLs:" ]
        , span [ class "badge badge-secondary" ] [ text "/getting-started/this-is-hardcoded" ]
        ]


categoryListDropdown : Model -> Html Msg
categoryListDropdown model =
    div []
        [ div [ class "dropdown" ]
            [ a
                [ class "btn btn-secondary dropdown-toggle"
                , attribute "role" "button"
                , attribute "data-toggle" "dropdown"
                , attribute "aria-haspopup" "true"
                , attribute "aria-expanded" "false"
                ]
                [ text "Select Category" ]
            , div
                [ class "dropdown-menu", attribute "aria-labelledby" "dropdownMenuButton" ]
                (List.map
                    (\category ->
                        a [ class "dropdown-item", onClick (CategorySelected category.id) ] [ text category.name ]
                    )
                    model.categories
                )
            ]
        ]


articleInputs : Model -> CreateArticleInputs
articleInputs { title, desc, categoryId } =
    { title = Field.value title
    , desc = Field.value desc
    , category_id = Field.value categoryId
    }


save : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
save model nodeEnv organizationKey =
    let
        cmd =
            Task.attempt SaveArticleResponse (Reader.run (requestCreateArticle) ( nodeEnv, (articleInputs model) ))
    in
        ( model, cmd )


fetchCategories : NodeEnv -> ApiKey -> Cmd Msg
fetchCategories nodeEnv key =
    Task.attempt CategoriesLoaded (Reader.run (requestCategories) ( nodeEnv, key ))
