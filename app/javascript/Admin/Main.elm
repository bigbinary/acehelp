module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Navigation exposing (..)
import Page.Article.List as ArticleList
import Page.Article.Create as ArticleCreate
import Page.Url.List as UrlList
import Page.Url.Create as UrlCreate
import Page.Category.List as CategoryList
import Page.Category.Create as CategoryCreate
import Page.Integration as Integration
import Page.Errors as Errors
import Data.Organization exposing (OrganizationId)
import Data.CategoryData exposing (Category)
import Data.ArticleData exposing (ArticleSummary)
import Data.UrlData exposing (UrlData)
import UrlParser as Url exposing (..)
import Request.RequestHelper exposing (NodeEnv, ApiKey, logoutRequest)
import Route
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient
import Reader exposing (Reader)
import Task exposing (Task)


-- MODEL


type alias Flags =
    { node_env : String
    , organization_key : String
    }


type Page
    = ArticleList ArticleList.Model
    | ArticleCreate ArticleCreate.Model
    | CategoryList CategoryList.Model
    | CategoryCreate CategoryCreate.Model
    | UrlList UrlList.Model
    | UrlCreate UrlCreate.Model
    | Integration Integration.Model
    | Dashboard
    | NotFound
    | Blank


type PageState
    = Loaded Page
    | TransitioningTo Page


type alias Model =
    { currentPage : PageState
    , route : Route.Route
    , nodeEnv : String
    , organizationKey : String
    }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        ( pageModel, pageCmd ) =
            setRoute location initModel

        initModel =
            { currentPage = Loaded Blank
            , route = Route.fromLocation location
            , nodeEnv = flags.node_env
            , organizationKey = flags.organization_key
            }
    in
        ( initModel, pageCmd )



-- MSG


type Msg
    = NavigateTo Route.Route
    | ArticleListMsg ArticleList.Msg
    | ArticleCreateMsg ArticleCreate.Msg
    | ArticlesLoaded (Result GQLClient.Error (List UrlData))
    | UrlCreateMsg UrlCreate.Msg
    | UrlListMsg UrlList.Msg
    | UrlsLoaded (Result GQLClient.Error (List UrlData))
    | CategoryListMsg CategoryList.Msg
    | CategoryCreateMsg CategoryCreate.Msg
    | CategoriesLoaded (Result GQLClient.Error (List Category))
    | IntegrationMsg Integration.Msg
    | OnLocationChange Navigation.Location
    | SignOut
    | SignedOut (Result Http.Error String)



-- UPDATE


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningTo page ->
            page


setRoute : Location -> Model -> ( Model, Cmd Msg )
setRoute location model =
    let
        newRoute =
            Route.fromLocation location
    in
        navigateTo newRoute model


navigateTo : Route.Route -> Model -> ( Model, Cmd Msg )
navigateTo newRoute model =
    let
        transitionTo page msg =
            Tuple.mapFirst
                (\pageModel -> ({ model | currentPage = TransitioningTo (page pageModel), route = newRoute }))
                >> Tuple.mapSecond
                    (Cmd.map msg)
    in
        case newRoute of
            Route.ArticleList ->
                let
                    ( articleListModel, articleListRequest ) =
                        ArticleList.init

                    cmd =
                        Task.attempt ArticlesLoaded (Reader.run (articleListRequest) (model.nodeEnv))
                in
                    ( { model | currentPage = TransitioningTo (ArticleList articleListModel), route = newRoute }, cmd )

            Route.ArticleCreate ->
                (ArticleCreate.init model.nodeEnv model.organizationKey)
                    |> transitionTo ArticleCreate ArticleCreateMsg

            Route.CategoryList ->
                let
                    ( categoryListModel, categoriesRequest ) =
                        CategoryList.init

                    cmd =
                        Task.attempt CategoriesLoaded (Reader.run (categoriesRequest) ( model.nodeEnv, model.organizationKey ))
                in
                    ( { model | currentPage = TransitioningTo (CategoryList categoryListModel), route = newRoute }, cmd )

            Route.CategoryCreate ->
                (CategoryCreate.init)
                    |> transitionTo CategoryCreate CategoryCreateMsg

            Route.UrlList ->
                let
                    ( urlListModel, urlListRequest ) =
                        UrlList.init

                    cmd =
                        Task.attempt UrlsLoaded (Reader.run (urlListRequest) (model.nodeEnv))
                in
                    ( { model | currentPage = TransitioningTo (UrlList urlListModel), route = newRoute }, cmd )

            Route.UrlCreate ->
                (UrlCreate.init)
                    |> transitionTo UrlCreate UrlCreateMsg

            Route.Integration ->
                (Integration.init model.organizationKey)
                    |> transitionTo Integration IntegrationMsg

            Route.Dashboard ->
                ( { model | currentPage = Loaded Blank }, Cmd.none )

            Route.NotFound ->
                ( { model | currentPage = Loaded NotFound }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavigateTo route ->
            navigateTo route model
                |> Tuple.mapSecond
                    (\cmd -> Cmd.batch <| cmd :: [ modifyUrl <| Route.routeToString route ])

        ArticleListMsg alMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (ArticleList articleListModel) ->
                            articleListModel

                        _ ->
                            ArticleList.initModel

                ( articleListModel, articleListCmd ) =
                    ArticleList.update alMsg currentPageModel model.organizationKey model.nodeEnv
            in
                ( { model | currentPage = Loaded (ArticleList articleListModel) }
                , Cmd.map ArticleListMsg articleListCmd
                )

        ArticlesLoaded (Ok urlsList) ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (ArticleList articleListModel) ->
                            { articleListModel | urlList = urlsList }

                        _ ->
                            ArticleList.initModel
            in
                ( { model | currentPage = Loaded (ArticleList currentPageModel) }
                , Cmd.none
                )

        ArticlesLoaded (Err error) ->
            ( model, Cmd.none )

        ArticleCreateMsg caMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (ArticleCreate articleCreateModel) ->
                            articleCreateModel

                        _ ->
                            ArticleCreate.initModel

                ( articleCreateModel, createArticleCmd ) =
                    ArticleCreate.update caMsg currentPageModel model.nodeEnv model.organizationKey
            in
                ( { model | currentPage = Loaded (ArticleCreate articleCreateModel) }
                , Cmd.map ArticleCreateMsg createArticleCmd
                )

        UrlCreateMsg cuMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (UrlCreate urlCreateModel) ->
                            urlCreateModel

                        _ ->
                            UrlCreate.initModel

                ( createUrlModel, createUrlCmds ) =
                    UrlCreate.update cuMsg currentPageModel model.nodeEnv model.organizationKey
            in
                ( { model | currentPage = Loaded (UrlCreate createUrlModel) }
                , Cmd.map UrlCreateMsg createUrlCmds
                )

        UrlListMsg ulMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (UrlList urlListModel) ->
                            urlListModel

                        _ ->
                            UrlList.initModel

                ( urlListModel, urlListCmds ) =
                    UrlList.update ulMsg currentPageModel
            in
                ( { model | currentPage = Loaded (UrlList urlListModel) }
                , Cmd.map UrlListMsg urlListCmds
                )

        UrlsLoaded (Ok urlsList) ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (UrlList urlListModel) ->
                            { urlListModel | urls = urlsList }

                        _ ->
                            UrlList.initModel
            in
                ( { model | currentPage = Loaded (UrlList currentPageModel) }
                , Cmd.none
                )

        UrlsLoaded (Err error) ->
            ( model, Cmd.none )

        CategoryListMsg clMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (CategoryList categoryListModel) ->
                            categoryListModel

                        _ ->
                            CategoryList.initModel

                ( categoryListModel, categoryListCmd ) =
                    CategoryList.update clMsg currentPageModel
            in
                ( { model | currentPage = Loaded (CategoryList categoryListModel) }
                , Cmd.map CategoryListMsg categoryListCmd
                )

        CategoriesLoaded (Ok categoriesList) ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (CategoryList categoryListModel) ->
                            { categoryListModel | categories = categoriesList }

                        _ ->
                            CategoryList.initModel
            in
                ( { model | currentPage = Loaded (CategoryList currentPageModel) }
                , Cmd.none
                )

        CategoriesLoaded (Err err) ->
            ( model, Cmd.none )

        CategoryCreateMsg ccMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (CategoryCreate categoryCreateModel) ->
                            categoryCreateModel

                        _ ->
                            CategoryCreate.initModel

                ( categoryCreateModel, categoryCreateCmd ) =
                    CategoryCreate.update ccMsg currentPageModel model.nodeEnv model.organizationKey
            in
                ( { model
                    | currentPage = Loaded (CategoryCreate categoryCreateModel)
                  }
                , Cmd.map CategoryCreateMsg categoryCreateCmd
                )

        IntegrationMsg integrationMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (Integration integrationPageModel) ->
                            integrationPageModel

                        _ ->
                            Integration.initModel model.organizationKey

                ( integrationModel, integrationCmd ) =
                    Integration.update integrationMsg currentPageModel
            in
                ( { model
                    | currentPage = Loaded (Integration integrationModel)
                  }
                , Cmd.map IntegrationMsg integrationCmd
                )

        OnLocationChange location ->
            setRoute location model

        SignOut ->
            ( model, Http.send SignedOut (logoutRequest model.nodeEnv) )

        SignedOut _ ->
            ( model, load (Request.RequestHelper.baseUrl model.nodeEnv) )


retriveOrganizationFromUrl : Location -> OrganizationId
retriveOrganizationFromUrl location =
    let
        org =
            parsePath (Url.s "admin" </> Url.s "organization" </> string) location
    in
        getOrganizationId (org)


getOrganizationId : Maybe String -> OrganizationId
getOrganizationId orgId =
    case orgId of
        Just orgId ->
            orgId

        Nothing ->
            ""



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case (getPage model.currentPage) of
        ArticleList articleListModel ->
            adminLayout model
                (Html.map ArticleListMsg
                    (ArticleList.view articleListModel)
                )

        ArticleCreate articleCreateModel ->
            adminLayout model
                (Html.map ArticleCreateMsg
                    (ArticleCreate.view articleCreateModel)
                )

        UrlCreate urlCreateModel ->
            adminLayout model
                (Html.map UrlCreateMsg
                    (UrlCreate.view urlCreateModel)
                )

        UrlList urlListModel ->
            adminLayout model
                (Html.map UrlListMsg
                    (UrlList.view urlListModel)
                )

        CategoryList categoryListModel ->
            adminLayout model
                (Html.map CategoryListMsg
                    (CategoryList.view categoryListModel)
                )

        CategoryCreate categoryCreateModel ->
            adminLayout model
                (Html.map CategoryCreateMsg
                    (CategoryCreate.view categoryCreateModel)
                )

        Integration integrationModel ->
            adminLayout model
                (Html.map IntegrationMsg
                    (Integration.view integrationModel)
                )

        Dashboard ->
            div [] [ text "Dashboard" ]

        NotFound ->
            Errors.notFound

        Blank ->
            div [] [ text "blank" ]


adminLayout : Model -> Html Msg -> Html Msg
adminLayout model page =
    div []
        [ adminHeader model
        , div [ class "container-fluid p-3" ] [ page ]
        ]


adminHeader : Model -> Html Msg
adminHeader model =
    nav [ class "navbar navbar-dark bg-primary navbar-expand flex-column flex-md-row" ]
        [ ul
            [ class "navbar-nav mr-auto mt-2 mt-lg-0 " ]
            [ li [ class "nav-item" ]
                [ Html.a
                    [ classList
                        [ ( "nav-link", True )
                        , ( "active", (model.route == Route.ArticleList) || (model.route == Route.ArticleCreate) )
                        ]
                    , onClick <| NavigateTo Route.ArticleList
                    ]
                    [ text "Articles" ]
                ]
            , li [ class "nav-item" ]
                [ Html.a
                    [ classList
                        [ ( "nav-link", True )
                        , ( "active", (model.route == Route.UrlList) || (model.route == Route.UrlCreate) )
                        ]
                    , onClick <| NavigateTo Route.UrlList
                    ]
                    [ text "URL" ]
                ]
            , li [ class "nav-item" ]
                [ Html.a
                    [ classList
                        [ ( "nav-link", True )
                        , ( "active", (model.route == Route.CategoryList) || (model.route == Route.CategoryCreate) )
                        ]
                    , onClick <| NavigateTo Route.CategoryList
                    ]
                    [ text "Category" ]
                ]
            , li [ class "nav-item" ]
                [ Html.a
                    [ classList
                        [ ( "nav-link", True )
                        , ( "active", model.route == Route.Integration )
                        ]
                    , onClick <| NavigateTo Route.Integration
                    ]
                    [ text "Integrations" ]
                ]
            ]
        , ul [ class "navbar-nav ml-auto" ]
            [ li [ class "nav-item " ] [ Html.a [ class "nav-link", onClick SignOut ] [ text "Logout" ] ] ]
        ]



-- MAIN


main : Program Flags Model Msg
main =
    Navigation.programWithFlags OnLocationChange
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
