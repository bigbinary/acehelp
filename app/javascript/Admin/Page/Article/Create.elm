module Page.Article.Create exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Data.ArticleData exposing (..)
import Request.ArticleRequest exposing (..)
import Request.CategoryRequest exposing (..)
import Request.Helpers exposing (NodeEnv, ApiKey)
import Data.CommonData exposing (Error)
import Data.CategoryData exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient


-- Model


type alias Model =
    { title : String
    , titleError : Error
    , desc : String
    , descError : Error
    , keywords : String
    , keywordError : Error
    , articleId : ArticleId
    , categories : List Category
    , categoryId : String
    , categoryIdError : Error
    , error : Error
    }


initModel : Model
initModel =
    { title = ""
    , titleError = Nothing
    , desc = ""
    , descError = Nothing
    , keywords = ""
    , keywordError = Nothing
    , articleId = "0"
    , categories = []
    , categoryId = "0"
    , categoryIdError = Nothing
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
            ( { model | title = title }, Cmd.none )

        DescInput desc ->
            ( { model | desc = desc }, Cmd.none )

        KeywordsInput keywords ->
            ( { model | keywords = keywords }, Cmd.none )

        SaveArticle ->
            let
                validArticleModel =
                    validate model
            in
                if isValid validArticleModel then
                    save validArticleModel nodeEnv organizationKey
                else
                    ( model, Cmd.none )

        SaveArticleResponse (Ok id) ->
            ( { model
                | title = ""
                , titleError = Nothing
                , desc = ""
                , descError = Nothing
                , keywords = ""
                , keywordError = Nothing
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
            ( { model | categoryId = categoryId }, Cmd.none )

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
                    , value model.title
                    , type_ "text"
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Description: " ]
                , textarea
                    [ placeholder "Short description about article..."
                    , onInput DescInput
                    , value model.desc
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Keywords: " ]
                , input
                    [ placeholder "Keywords..."
                    , onInput KeywordsInput
                    , value model.keywords
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
                        [ value "0" ]
                        [ text "Select Category" ]
                  ]
                , (List.map
                    (\category ->
                        option
                            [ value category.id ]
                            [ text category.name ]
                    )
                    model.categories
                  )
                ]
            )
        ]


articleInputs : Model -> CreateArticleInputs
articleInputs { title, desc, categoryId } =
    { title = title
    , desc = desc
    , category_id = categoryId
    }


save : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
save model nodeEnv organizationKey =
    let
        cmd =
            Task.attempt SaveArticleResponse (Reader.run (requestCreateArticle) ( nodeEnv, (articleInputs model) ))
    in
        ( model, cmd )


validate : Model -> Model
validate model =
    model
        |> validateTitle
        |> validateDesc
        |> validateKeyword
        |> validateCategoryId


validateTitle : Model -> Model
validateTitle model =
    if String.isEmpty model.title then
        { model
            | titleError =
                Just "Title should be present"
        }
    else
        { model
            | titleError = Nothing
        }


validateDesc : Model -> Model
validateDesc model =
    if String.isEmpty model.desc then
        { model
            | descError =
                Just "Desc is required"
        }
    else
        { model
            | descError = Nothing
        }


validateKeyword : Model -> Model
validateKeyword model =
    if String.isEmpty model.keywords then
        { model
            | keywordError =
                Just "Keyword is required"
        }
    else
        { model
            | keywordError = Nothing
        }


validateCategoryId : Model -> Model
validateCategoryId model =
    if String.isEmpty model.categoryId then
        { model
            | categoryIdError = Just "category ID required"
        }
    else if model.categoryId == "0" then
        { model
            | categoryIdError = Just "Please select category"
        }
    else
        { model
            | categoryIdError = Nothing
        }


isValid : Model -> Bool
isValid model =
    model.titleError
        == Nothing
        && model.descError
        == Nothing
        && model.keywordError
        == Nothing
        && model.categoryIdError
        == Nothing
