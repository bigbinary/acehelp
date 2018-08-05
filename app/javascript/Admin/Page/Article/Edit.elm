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
import Time
import Field exposing (..)
import Field.ValidationResult exposing (..)
import Helpers exposing (..)
import Admin.Ports exposing (..)
import GraphQL.Client.Http as GQLClient
import Admin.Ports exposing (..)


-- Model


type alias Model =
    { title : Field String String
    , desc : Field String String
    , articleId : ArticleId
    , categories : List Category
    , categoryId : Maybe CategoryId
    , error : Maybe String
    , keyboardInputTaskId : Maybe Int
    }


initModel : ArticleId -> Model
initModel articleId =
    { title = Field (validateEmpty "Title") ""
    , desc = Field (validateEmpty "Article Content") ""
    , articleId = articleId
    , categories = []
    , categoryId = Nothing
    , error = Nothing
    , keyboardInputTaskId = Nothing
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
    | TrixInitialize ()
    | ReceivedTimeoutId Int
    | TimedOut Int
    | Killed ()



-- TODO: Fetch categories to populate categories dropdown


delayTime : Float
delayTime =
    Time.second * 3


update : Msg -> Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
update msg model nodeEnv organizationKey =
    case msg of
        TitleInput title ->
            let
                newTitle =
                    Field.update model.title title

                errors =
                    errorsIn [ newTitle, model.desc ]
            in
                ( { model | title = newTitle, error = errors }, setTimeout delayTime )

        ReceivedTimeoutId id ->
            let
                killCmd =
                    case model.keyboardInputTaskId of
                        Just oldId ->
                            clearTimeout oldId

                        Nothing ->
                            Cmd.none
            in
                ( { model | keyboardInputTaskId = Just id }, killCmd )

        TimedOut id ->
            save model nodeEnv organizationKey

        DescInput desc ->
            let
                newDesc =
                    Field.update model.desc desc

                errors =
                    errorsIn [ newDesc, model.title ]
            in
                ( { model | desc = newDesc, error = errors }, Cmd.none )

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
            ( { model | error = Just (toString error) }, Cmd.none )

        ArticleLoaded (Ok article) ->
            ( { model
                | articleId = article.id
                , title = Field.update model.title article.title
                , desc = Field.update model.desc article.desc
                , categories = article.categories
              }
            , insertArticleContent article.desc
            )

        ArticleLoaded (Err err) ->
            ( { model | error = Just "There was an error loading up the article" }
            , Cmd.none
            )

        CategoriesLoaded (Ok categories) ->
            ( { model | categories = categories }, Cmd.none )

        CategoriesLoaded (Err err) ->
            ( { model | error = Just (toString err) }, Cmd.none )

        CategorySelected categoryId ->
            let
                newCategoryId =
                    Just categoryId

                errors =
                    errorsIn [ model.desc, model.title ]
            in
                ( { model | categoryId = newCategoryId, error = errors }, Cmd.none )

        TrixInitialize _ ->
            ( model, insertArticleContent <| Field.value model.desc )

        Killed _ ->
            ( model, Cmd.none )


errorsIn : List (Field String v) -> Maybe String
errorsIn fields =
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
        |> stringToMaybe



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
                    [ node "trix-editor"
                        [ placeholder "Article content goes here.."
                        , onInput DescInput
                        ]
                        []
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
                div
                    [ class "alert alert-danger alert-dismissible fade show"
                    , attribute "role" "alert"
                    ]
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
            List.filter (\category -> category.id == Maybe.withDefault "" model.categoryId)
                model.categories
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
                    [ class "dropdown-menu"
                    , attribute
                        "aria-labelledby"
                        "dropdownMenuButton"
                    ]
                    (List.map
                        (\category ->
                            a
                                [ class "dropdown-item"
                                , onClick
                                    (CategorySelected category.id)
                                ]
                                [ text category.name ]
                        )
                        model.categories
                    )
                ]
            ]


articleInputs : Model -> UpdateArticleInputs
articleInputs { articleId, title, desc, categoryId } =
    { id = articleId
    , title = Field.value title
    , desc = Field.value desc
    , categoryId = categoryId
    }


save : Model -> NodeEnv -> ApiKey -> ( Model, Cmd Msg )
save model nodeEnv organizationKey =
    let
        fields =
            [ model.title, model.desc ]

        cmd =
            Task.attempt SaveArticleResponse
                (Reader.run
                    (requestUpdateArticle (articleInputs model))
                    ( nodeEnv, organizationKey )
                )
    in
        if Field.isAllValid fields then
            ( { model | error = Nothing }, cmd )
        else
            ( { model | error = errorsIn fields }, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ trixInitialize <| TrixInitialize
        , trixChange <| DescInput
        , timeoutInitialized <| ReceivedTimeoutId
        , timedOut <| TimedOut
        ]
