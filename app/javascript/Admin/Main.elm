module Main exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)


--import Data.ArticleData exposing (..)

import Page.ArticlesListPage as ArticlesListPage
import Page.CreateArticlePage as CreateArticlePage


-- MODEL


type alias Model =
    { currentPage : Page
    , articlesListPage : ArticlesListPage.Model
    , createArticlePage : CreateArticlePage.Model
    , mockValue : String
    }


type Page
    = ArticlesListPage
    | CreateArticlePage
    | NotFoundPage



--initModel : Page -> Model
--initModel page =
--    { currentPage = page
--    , articlesListPage = ArticlesListPage.initModel
--    , createArticlePage = CreateArticlePage.initModel
--    , mockValue = "Howdy!"
--    }


init : Location -> ( Model, Cmd Msg )
init location =
    let
        page =
            retrivePage location.hash

        ( articleListModel, articleListCmds ) =
            ArticlesListPage.init

        --(createArticleModel, createArticleCmds) =
        --    CreateArticlePage.initModel
        initModel =
            { currentPage = page
            , articlesListPage = articleListModel
            , createArticlePage = CreateArticlePage.initModel
            , mockValue = "Howdy"
            }

        cmds =
            Cmd.batch
                [ Cmd.map ArticlesListMsg articleListCmds

                --, Cmd.map
                ]
    in
        ( initModel, cmds )



-- MSG


type Msg
    = Navigate Page
    | ChangePage Page
    | ArticlesListMsg ArticlesListPage.Msg



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Navigate page ->
            ( model, newUrl <| convertPageToHash page )

        ChangePage page ->
            ( { model | currentPage = page }, Cmd.none )

        ArticlesListMsg alMsg ->
            let
                ( articleListModel, articleListCmd ) =
                    ArticlesListPage.update alMsg model.articlesListPage
            in
                ( { model | articlesListPage = articleListModel }
                , Cmd.map ArticlesListMsg articleListCmd
                )


convertPageToHash : Page -> String
convertPageToHash page =
    case page of
        ArticlesListPage ->
            "/admin/articles"

        CreateArticlePage ->
            "/admin/articles/create"

        NotFoundPage ->
            "/404"


urlLocationToMsg : Location -> Msg
urlLocationToMsg location =
    location.hash
        |> retrivePage
        |> ChangePage


retrivePage : String -> Page
retrivePage hash =
    case hash of
        "/admin/articles" ->
            ArticlesListPage

        "/admin/articles/create" ->
            CreateArticlePage

        _ ->
            NotFoundPage



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    let
        page =
            case model.currentPage of
                _ ->
                    Html.map ArticlesListMsg
                        (ArticlesListPage.view model.articlesListPage)
    in
        div []
            [ adminHeader model
            , page
            ]


adminHeader : Model -> Html Msg
adminHeader model =
    div [ class "header" ]
        [ div [ class "header-right" ]
            [ Html.a [ onClick (Navigate ArticlesListPage) ] [ text "Articles" ]
            , Html.a [ href "urls" ] [ text "URL" ]
            ]
        ]



-- MAIN


main : Program Never Model Msg
main =
    Navigation.program urlLocationToMsg
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
