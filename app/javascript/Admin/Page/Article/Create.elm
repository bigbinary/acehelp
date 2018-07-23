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
    div [ class "container" ]
        [ Html.form
            [ onSubmit SaveArticle ]
            [ div []
                [ label [] [ text "Title: " ]
                , input
                    [ placeholder "Title..."
                    , onInput TitleInput
                    , Html.Attributes.value <| Field.value model.title
                    , type_ "text"
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Description: " ]
                , textarea
                    [ placeholder "Short description about article..."
                    , onInput DescInput
                    , Html.Attributes.value <| Field.value model.desc
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Keywords: " ]
                , input
                    [ placeholder "Keywords..."
                    , onInput KeywordsInput
                    , Html.Attributes.value <| Field.value model.keywords
                    , type_ "text"
                    ]
                    []
                ]
            , div []
                [ categoryListDropdown model
                ]
            , div []
                [ button
                    [ type_ "submit"
                    , class "button primary"
                    ]
                    [ text "Submit" ]
                ]
            ]
        ]


categoryListDropdown : Model -> Html Msg
categoryListDropdown model =
    div
        []
        [ select
            [ onInput CategorySelected ]
            (List.concat
                [ [ option
                        [ Html.Attributes.value "0" ]
                        [ text "Select Category" ]
                  ]
                , (List.map
                    (\category ->
                        option
                            [ Html.Attributes.value category.id ]
                            [ text category.name ]
                    )
                    model.categories
                  )
                ]
            )
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
