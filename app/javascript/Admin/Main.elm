module Main exposing (..)

import Html exposing (Html, div, text, button)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)
import Page.Article.List as ArticlesList
import Page.Article.Create as CreateArticle
import Page.Url.List as ListUrls
import Page.Url.Create as CreateUrl
import Page.Category.List as CategoryList
import Page.Category.Create as CategoryCreate
import Page.Organization.Show as OrganizationShow
import Data.OrganizationData exposing (OrganizationId)
import UrlParser as Url exposing (..)


-- MODEL


type alias Flags =
    { node_env : String
    }


type alias Model =
    { currentPage : Page
    , articlesList : ArticlesList.Model
    , createArticle : CreateArticle.Model
    , listUrl : ListUrls.Model
    , createUrl : CreateUrl.Model
    , categoryList : CategoryList.Model
    , categoryCreate : CategoryCreate.Model
    , organizationShow : OrganizationShow.Model
    , location : Location
    }

type Page
    = ArticlesList
    | UrlList
    | UrlCreate
    | CreateArticle
    | CategoryList
    | CategoryCreate
    | OrganizationShow
    | NotFound


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        page =
            retrivePage (extractStaticPath location)

        ( createArticleModel, createArticleCmds ) =
            CreateArticle.init

        ( articleListModel, articleListCmds ) =
            ArticlesList.init

        ( createUrlModel, createUrlCmds ) =
            CreateUrl.init

        ( urlListModel, urlListCmds ) =
            ListUrls.init

        ( categoryListModel, categoryListCmds ) =
            CategoryList.init

        ( categoryCreateModel, categoryCreateCmds ) =
            CategoryCreate.init

        ( organizationShowModel, organizationShowCmds ) =
            OrganizationShow.init (retriveOrganizationFromUrl location)

        initModel =
            { currentPage = page
            , articlesList = articleListModel
            , createArticle = createArticleModel
            , listUrl = urlListModel
            , createUrl = createUrlModel
            , categoryList = categoryListModel
            , categoryCreate = categoryCreateModel
            , organizationShow = organizationShowModel
            , location = location
            }


        cmds =
            Cmd.batch
                [ Cmd.map ArticlesListMsg articleListCmds
                , Cmd.map CreateArticleMsg createArticleCmds
                , Cmd.map CreateUrlMsg createUrlCmds
                , Cmd.map UrlListMsg urlListCmds
                , Cmd.map CategoryListMsg categoryListCmds
                , Cmd.map CategoryCreateMsg categoryCreateCmds
                , Cmd.map OrganizationShowMsg organizationShowCmds
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
    | CategoryListMsg CategoryList.Msg
    | CategoryCreateMsg CategoryCreate.Msg
    | OrganizationShowMsg OrganizationShow.Msg


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

        CategoryListMsg clMsg ->
            let
                ( categoryListModel, categoryListCmd ) =
                    CategoryList.update clMsg model.categoryList
            in
                ( { model | categoryList = categoryListModel }
                , Cmd.map CategoryListMsg categoryListCmd
                )

        CategoryCreateMsg ccMsg ->
            let
                ( categoryCreateModel, categoryCreateCmd ) =
                    CategoryCreate.update ccMsg model.categoryCreate
            in
                ( { model
                    | categoryCreate = categoryCreateModel
                  }
                , Cmd.map CategoryCreateMsg categoryCreateCmd
                )

        OrganizationShowMsg osMsg ->
            let
                ( organizationShowModel, organizationShowCmds ) =
                    OrganizationShow.update osMsg model.organizationShow
            in
                ( { model | organizationShow = organizationShowModel }
                , Cmd.map OrganizationShowMsg organizationShowCmds
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

        CategoryList ->
            "/admin/categories"

        CategoryCreate ->
            "/admin/categories/new"

        OrganizationShow ->
            "/admin/organization/1"

        NotFound ->
            "/404"


urlLocationToMsg : Location -> Msg
urlLocationToMsg location =
    extractStaticPath location
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

        "/admin/categories" ->
            CategoryList

        "/admin/categories/new" ->
            CategoryCreate

        "/admin/organization/1" ->
            OrganizationShow

        "/admin/organization/2" ->
            OrganizationShow

        _ ->
            NotFound


extractStaticPath : Location -> String
extractStaticPath location =
        let
            staticPath = parsePath ( s "admin" </> string ) location

            path =
                case staticPath of
                    Nothing ->
                        location.pathname

                    Just staticPath ->
                        staticPath
        in
            case path of
            "organization" ->
                "/admin/organization"
            _ ->
               location.pathname



retriveOrganizationFromUrl : Location -> OrganizationId
retriveOrganizationFromUrl location =
   let
      org = parsePath (s "admin" </> s "organization" </> int) location
   in
       getOrganizationId ( org )


getOrganizationId : Maybe Int -> OrganizationId
getOrganizationId orgId =
    case orgId of
        Just orgId ->
          orgId

        Nothing ->
          2



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

                CategoryList ->
                    Html.map CategoryListMsg
                        (CategoryList.view model.categoryList)

                CategoryCreate ->
                    Html.map CategoryCreateMsg
                        (CategoryCreate.view model.categoryCreate)

                OrganizationShow ->
                    Html.map OrganizationShowMsg
                        (OrganizationShow.view model.organizationShow)

                _ ->
                    div [] [ text "Not Found" ]
    in
        div []
            [ adminHeader model
            , page
            ]


adminHeader : Model -> Html Msg
adminHeader model =
    div [ class "header" ]
        [ div [ class "header-right" ]
            [ Html.a [ onClick (Navigate ArticlesList) ] [ text "Articles" ]
            , Html.a [ onClick (Navigate UrlList) ] [ text "URL" ]
            , Html.a [ onClick (Navigate CategoryList) ] [ text "Category" ]
            , Html.a [ onClick (Navigate OrganizationShow) ] [ text "Organization" ]
            ]
        ]


-- MAIN


main : Program Flags Model Msg
main =
    Navigation.programWithFlags urlLocationToMsg
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
