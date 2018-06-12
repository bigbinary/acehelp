module Main exposing (..)

import Html exposing (Html, div, text, button)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)
import Page.ArticlesListPage as ArticlesList
import Page.CreateArticlePage as CreateArticle
import Page.UrlListPage as ListUrls
import Page.UrlCreatePage as CreateUrl


-- MODEL


type alias Model =
    { currentPage : Page
    , articlesList : ArticlesList.Model
    , createArticle : CreateArticle.Model
    , listUrl : ListUrls.Model
    , createUrl : CreateUrl.Model
    , location : Location
    }


type Page
    = ArticlesList
    | UrlList
    | UrlCreate
    | CreateArticle
    | NotFound


init : Location -> ( Model, Cmd Msg )
init location =
    let
        page =
            retrivePage location.pathname

        ( articleListModel, articleListCmds ) =
            ArticlesList.init

        ( createArticleModel, createArticleCmds ) =
            CreateArticle.init

        ( createUrlModel, createUrlCmds ) =
            CreateUrl.init

        ( urlListModel, urlListCmds ) =
            ListUrls.init

        initModel =
            { currentPage = page
            , articlesList = articleListModel
            , createArticle = createArticleModel
            , listUrl = urlListModel
            , createUrl = createUrlModel
            , location = location
            }

        cmds =
            Cmd.batch
                [ Cmd.map ArticlesListMsg articleListCmds
                , Cmd.map CreateArticleMsg createArticleCmds
                , Cmd.map CreateUrlMsg createUrlCmds
                , Cmd.map UrlListMsg urlListCmds
                ]
    in
        ( initModel, cmds )



-- MSG


type Msg
    = Navigate Page
    | ChangePage Page
    | ArticlesListMsg ArticlesList.Msg
    | CreateArticleMsg CreateArticle.Msg
    | CreateUrlMsg CreateUrl.Msg
    | UrlListMsg ListUrls.Msg



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
                    ArticlesList.update alMsg model.articlesList
            in
                ( { model | articlesList = articleListModel }
                , Cmd.map ArticlesListMsg articleListCmd
                )

        CreateArticleMsg caMsg ->
            let
                ( createArticleModel, createArticleCmd ) =
                    CreateArticle.update caMsg model.createArticle
            in
                ( { model | createArticle = createArticleModel }
                , Cmd.map CreateArticleMsg createArticleCmd
                )

        CreateUrlMsg cuMsg ->
            let
                ( createUrlModel, createUrlCmds ) =
                    CreateUrl.update cuMsg model.createUrl
            in
                ( { model | createUrl = createUrlModel }
                , Cmd.map CreateUrlMsg createUrlCmds
                )

        UrlListMsg ulMsg ->
            let
                ( urlListModel, urlListCmds ) =
                    ListUrls.update ulMsg model.listUrl
            in
                ( { model | listUrl = urlListModel }
                , Cmd.map UrlListMsg urlListCmds
                )


convertPageToHash : Page -> String
convertPageToHash page =
    case page of
        ArticlesList ->
            "/admin/articles"

        CreateArticle ->
            "/admin/articles/new"

        UrlList ->
            "/admin/urls"

        UrlCreate ->
            "/admin/urls/new"

        NotFound ->
            "/404"


urlLocationToMsg : Location -> Msg
urlLocationToMsg location =
    location.pathname
        |> retrivePage
        |> ChangePage


retrivePage : String -> Page
retrivePage pathname =
    case pathname of
        "/admin/articles" ->
            ArticlesList

        "/admin/articles/new" ->
            CreateArticle

        "/admin/urls" ->
            UrlList

        "/admin/urls/new" ->
            UrlCreate

        _ ->
            NotFound



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
                ArticlesList ->
                    Html.map ArticlesListMsg
                        (ArticlesList.view model.articlesList)

                CreateArticle ->
                    Html.map CreateArticleMsg
                        (CreateArticle.view model.createArticle)

                UrlCreate ->
                    Html.map CreateUrlMsg
                        (CreateUrl.view model.createUrl)

                UrlList ->
                    Html.map UrlListMsg
                        (ListUrls.view model.listUrl)

                _ ->
                    div [] [ text "Not Found" ]
    in
        div []
            [ adminHeader model
            , div
                [ style
                    [ ( "float", "right" )
                    ]
                , onClick (Navigate CreateArticle)
                ]
                [ button [ class "button primary" ] [ text "New Article" ]
                ]
            , page
            ]


adminHeader : Model -> Html Msg
adminHeader model =
    div [ class "header" ]
        [ div [ class "header-right" ]
            [ Html.a [ onClick (Navigate ArticlesList) ] [ text "Articles" ]
            , Html.a [ onClick (Navigate UrlList) ] [ text "URL" ]
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
