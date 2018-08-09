module Page.Article.Create exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Data.Article exposing (..)
import Admin.Request.Article exposing (..)
import Admin.Request.Category exposing (..)
import Admin.Request.Url exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Admin.Data.Category exposing (..)
import Admin.Data.Url exposing (UrlData, UrlId)
import Admin.Data.Common exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Time
import Field exposing (..)
import Field.ValidationResult exposing (..)
import Helpers exposing (..)
import Admin.Ports exposing (..)
import Page.Article.Common exposing (..)
import GraphQL.Client.Http as GQLClient
import Admin.Ports exposing (..)


-- Model


type alias Model =
    { title : Field String String
    , desc : Field String String
    , articleId : Maybe ArticleId
    , categories : List (Option Category)
    , urls : List (Option UrlData)
    , status : Status
    , error : Maybe String
    }


initModel : Model
initModel =
    { title = Field (validateEmpty "Title") ""
    , desc = Field (validateEmpty "Article Content") ""
    , articleId = Nothing
    , categories = []
    , urls = []
    , status = None
    , error = Nothing
    }


init : ( Model, Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Category)), Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List UrlData)) )
init =
    ( initModel
    , requestCategories
    , requestUrls
    )



-- Update


type Msg
    = TitleInput String
    | DescInput String
    | SaveArticle
    | SaveArticleResponse (Result GQLClient.Error Article)
    | CategoriesLoaded (Result GQLClient.Error (List Category))
    | CategorySelected (List CategoryId)
    | UrlsLoaded (Result GQLClient.Error (List UrlData))
    | UrlSelected (List UrlId)


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
    case msg of
        TitleInput title ->
            ( { model | title = Field.update model.title title }, Cmd.none )

        DescInput desc ->
            ( { model | desc = Field.update model.desc desc }, Cmd.none )

        SaveArticle ->
            save model nodeEnv organizationKey

        SaveArticleResponse (Ok id) ->
            ( { model
                | title = Field.update model.title ""
                , desc = Field.update model.desc ""
              }
            , Cmd.none
            )

        SaveArticleResponse (Err error) ->
            ( { model | error = Just (toString error), status = None }, Cmd.none )

        CategoriesLoaded (Ok categories) ->
            ( { model | categories = List.map Unselected categories, status = None }, Cmd.none )

        CategoriesLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        CategorySelected categoryIds ->
            ( { model | categories = itemSelection categoryIds model.categories }, Cmd.none )

        UrlsLoaded (Ok urls) ->
            ( { model | urls = List.map Unselected urls }, Cmd.none )

        UrlsLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        UrlSelected selectedUrlIds ->
            ( { model
                | urls =
                    itemSelection selectedUrlIds model.urls
              }
            , Cmd.none
            )



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
                    [ node "trix-editor"
                        [ placeholder "Article content goes here.."
                        , onInput DescInput
                        ]
                        []
                    ]
                ]
            , div [ class "col-sm article-meta-data-block" ]
                [ multiSelectCategoryList "Categories:" model.categories CategorySelected
                , multiSelectUrlList "Urls:" model.urls UrlSelected
                , button [ id "create-article", type_ "button", class "btn btn-success", onClick SaveArticle ] [ text "Create Article" ]
                ]
            ]
        , if model.status == Saving then
            savingIndicator
          else
            text ""
        ]


save : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
save model nodeEnv organizationKey =
    let
        fields =
            [ model.title, model.desc ]

        cmd =
            Task.attempt SaveArticleResponse
                (Reader.run
                    (requestCreateArticle (articleInputs model))
                    ( nodeEnv, organizationKey )
                )
    in
        if Field.isAllValid fields then
            ( { model | error = Nothing, status = Saving }, cmd )
        else
            ( { model | error = errorsIn fields }, Cmd.none )


articleInputs : Model -> CreateArticleInputs
articleInputs { title, desc, categories } =
    { title = Field.value title
    , desc = Field.value desc
    , categoryId =
        List.filterMap
            (\option ->
                case option of
                    Selected category ->
                        Just category.id

                    _ ->
                        Nothing
            )
            categories
            |> List.head
    }
