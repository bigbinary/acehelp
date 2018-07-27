module Page.Article.Edit exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Data.Article exposing (..)
import Admin.Request.Article exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Admin.Data.Category exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import Helpers exposing (..)
import Admin.Ports exposing (insertArticleContent)
import GraphQL.Client.Http as GQLClient


-- Model


type alias Model =
    { title : Field String String
    , desc : Field String String
    , articleId : ArticleId
    , categories : List Category
    , categoryId : Field String String
    , error : Maybe String
    }


initModel : ArticleId -> Model
initModel articleId =
    { title = Field (validateEmpty "Title") ""
    , desc = Field (validateEmpty "Article Content") ""
    , articleId = articleId
    , categories = []
    , categoryId = Field (validateEmpty "Category Id") ""
    , error = Nothing
    }


init : ArticleId -> ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Article) )
init articleId =
    ( initModel articleId
    , requestArticleById articleId
    )



-- Update


type Msg
    = TitleInput String
    | DescInput String
    | SaveArticle
    | SaveArticleResponse (Result GQLClient.Error Article)
    | ArticleLoaded (Result GQLClient.Error Article)
    | CategoriesLoaded (Result GQLClient.Error (List Category))
    | CategorySelected String



-- TODO: Fetch categories to populate categories dropdown


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
                    [ model.title, model.desc, model.categoryId ]

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
                    ( { model | error = Just <| Debug.log "" errors }, Cmd.none )

        SaveArticleResponse (Ok id) ->
            ( { model
                | title = Field.update model.title ""
                , desc = Field.update model.desc ""
              }
            , Cmd.none
            )

        SaveArticleResponse (Err error) ->
            ( { model | error = Just (toString error) }, Cmd.none )

        ArticleLoaded (Ok article) ->
            ( { model
                | title = Field.update model.title article.title
                , desc = Field.update model.desc article.desc
                , categoryId = Field.update model.categoryId article.category.id
              }
            , insertArticleContent article.desc
            )

        ArticleLoaded (Err err) ->
            ( { model | error = Just "There was an error loading up the article" }, Cmd.none )

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
        [ errorView model
        , div [ class "row article-block" ]
            [ div [ class "col-md-8 article-title-content-block" ]
                [ div
                    [ class "row article-title" ]
                    [ input
                        [ Html.Attributes.value <| Field.value model.title
                        , type_ "text"
                        , class "form-control"
                        , placeholder "Title"
                        , onInput TitleInput
                        ]
                        []
                    ]
                , div
                    [ class "row article-content" ]
                    [ node "trix-editor" [ placeholder "Article content goes here..", onInput DescInput ] []
                    ]
                ]
            , div [ class "col-sm article-meta-data-block" ]
                [ categoryListDropdown model
                , articleUrls model
                ]
            ]
        ]


errorView : Model -> Html Msg
errorView model =
    Maybe.withDefault (text "") <|
        Maybe.map
            (\err ->
                div [ class "alert alert-danger alert-dismissible fade show", attribute "role" "alert" ]
                    [ text <| "Error: " ++ err
                    ]
            )
            model.error


articleUrls : Model -> Html Msg
articleUrls model =
    div []
        [ h6 [] [ text "Linked URLs:" ]
        , span [ class "badge badge-secondary" ] [ text "/getting-started/this-is-hardcoded" ]
        ]


categoryListDropdown : Model -> Html Msg
categoryListDropdown model =
    let
        selectedCategory =
            List.filter (\category -> category.id == (Field.value model.categoryId)) model.categories
                |> List.map .name
                |> List.head
                |> Maybe.withDefault "Select Category"
    in
        div []
            [ div [ class "dropdown" ]
                [ a
                    [ class "btn btn-secondary dropdown-toggle"
                    , attribute "role" "button"
                    , attribute "data-toggle" "dropdown"
                    , attribute "aria-haspopup" "true"
                    , attribute "aria-expanded" "false"
                    ]
                    [ text selectedCategory ]
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
    , categoryId = Just (Field.value categoryId)
    }


save : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
save model nodeEnv organizationKey =
    let
        cmd =
            Task.attempt SaveArticleResponse (Reader.run (requestCreateArticle (articleInputs model)) nodeEnv)
    in
        ( model, cmd )
