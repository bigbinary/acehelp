module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Navigation exposing (..)
import Page.Article.List as ArticleList
import Page.Article.Create as ArticleCreate
import Page.Article.Edit as ArticleEdit
import Page.Url.List as UrlList
import Page.Url.Create as UrlCreate
import Page.Url.Edit as UrlEdit
import Page.Category.List as CategoryList
import Page.Ticket.List as TicketList
import Page.Category.Create as CategoryCreate
import Page.Settings as Settings
import Page.Errors as Errors
import Admin.Data.Organization exposing (OrganizationId)
import Admin.Data.Category exposing (Category)
import Admin.Data.Url exposing (UrlData)
import UrlParser as Url exposing (..)
import Admin.Request.Helper exposing (NodeEnv, ApiKey, logoutRequest)
import Route
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient
import Reader exposing (Reader)
import Task exposing (Task)


-- MODEL


type alias Flags =
    { node_env : String
    , organization_key : String
    , user_id : String
    , user_email : String
    }


type Page
    = ArticleList ArticleList.Model
    | ArticleCreate ArticleCreate.Model
    | ArticleEdit ArticleEdit.Model
    | CategoryList CategoryList.Model
    | CategoryCreate CategoryCreate.Model
    | UrlList UrlList.Model
    | UrlCreate UrlCreate.Model
    | UrlEdit UrlEdit.Model
    | Settings Settings.Model
    | TicketList TicketList.Model
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
    , userId : String
    , userEmail : String
    , error : Maybe String
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
            , userId = flags.user_id
            , userEmail = flags.user_email
            , error = Nothing
            }
    in
        ( initModel, pageCmd )



-- MSG


type Msg
    = NavigateTo Route.Route
    | ArticleListMsg ArticleList.Msg
    | ArticleCreateMsg ArticleCreate.Msg
    | ArticleCategoriesLoaded (Result GQLClient.Error (List Category))
    | ArticleEditMsg ArticleEdit.Msg
    | UrlCreateMsg UrlCreate.Msg
    | UrlEditMsg UrlEdit.Msg
    | UrlListMsg UrlList.Msg
    | UrlsLoaded (Result GQLClient.Error (List UrlData))
    | CategoryListMsg CategoryList.Msg
    | CategoryCreateMsg CategoryCreate.Msg
    | CategoriesLoaded (Result GQLClient.Error (List Category))
    | TicketListMsg TicketList.Msg
    | SettingsMsg Settings.Msg
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
                (\pageModel ->
                    ({ model
                        | currentPage =
                            TransitioningTo (page pageModel)
                        , route = newRoute
                     }
                    )
                )
                >> Tuple.mapSecond
                    (Cmd.map msg)
    in
        case newRoute of
            Route.ArticleList organizationKey ->
                let
                    ( articleListModel, articleListRequest ) =
                        ArticleList.init organizationKey

                    cmd =
                        Cmd.map ArticleListMsg <|
                            Task.attempt
                                ArticleList.ArticleListLoaded
                                (Reader.run (articleListRequest)
                                    ( model.nodeEnv
                                    , model.organizationKey
                                    )
                                )
                in
                    ( { model
                        | currentPage =
                            TransitioningTo
                                (ArticleList articleListModel)
                        , route = newRoute
                      }
                    , cmd
                    )

            Route.ArticleCreate organizationKey ->
                let
                    ( articleCreateModel, categoriesRequest ) =
                        ArticleCreate.init

                    cmd =
                        Task.attempt ArticleCategoriesLoaded
                            (Reader.run (categoriesRequest)
                                ( model.nodeEnv
                                , model.organizationKey
                                )
                            )
                in
                    ( { model
                        | currentPage =
                            TransitioningTo
                                (ArticleCreate articleCreateModel)
                        , route = newRoute
                      }
                    , cmd
                    )

            Route.CategoryList organizationKey ->
                let
                    ( categoryListModel, categoriesRequest ) =
                        CategoryList.init organizationKey

                    cmd =
                        Task.attempt CategoriesLoaded
                            (Reader.run
                                (categoriesRequest)
                                ( model.nodeEnv, model.organizationKey )
                            )
                in
                    ( { model
                        | currentPage =
                            TransitioningTo
                                (CategoryList
                                    categoryListModel
                                )
                        , route = newRoute
                      }
                    , cmd
                    )

            Route.CategoryCreate organizationKey ->
                (CategoryCreate.init)
                    |> transitionTo CategoryCreate CategoryCreateMsg

            Route.UrlList organizationKey ->
                let
                    ( urlListModel, urlListRequest ) =
                        UrlList.init organizationKey

                    cmd =
                        Task.attempt UrlsLoaded
                            (Reader.run
                                (urlListRequest)
                                ( model.nodeEnv, model.organizationKey )
                            )
                in
                    ( { model
                        | currentPage =
                            TransitioningTo
                                (UrlList urlListModel)
                        , route = newRoute
                      }
                    , cmd
                    )

            Route.UrlCreate organizationKey ->
                (UrlCreate.init)
                    |> transitionTo UrlCreate UrlCreateMsg

            Route.TicketList organizationKey ->
                (TicketList.init model.nodeEnv model.organizationKey)
                    |> transitionTo TicketList TicketListMsg

            Route.UrlEdit organizationKey urlId ->
                let
                    ( urlEditModel, urlEditCmd ) =
                        UrlEdit.init urlId

                    cmd =
                        Cmd.map UrlEditMsg <| Task.attempt (UrlEdit.UrlLoaded) (Reader.run (urlEditCmd) ( model.nodeEnv, model.organizationKey ))
                in
                    ( { model | currentPage = TransitioningTo (UrlEdit urlEditModel), route = newRoute }, cmd )

            Route.Settings organizationKey ->
                (Settings.init model.organizationKey)
                    |> transitionTo Settings SettingsMsg

            Route.Dashboard ->
                ( { model | currentPage = Loaded Blank }, Cmd.none )

            Route.ArticleEdit organizationKey articleId ->
                let
                    ( articleEditModel, articleEditCmd ) =
                        ArticleEdit.init articleId

                    cmd =
                        Cmd.map ArticleEditMsg <|
                            Task.attempt
                                (ArticleEdit.ArticleLoaded)
                                (Reader.run (articleEditCmd)
                                    ( model.nodeEnv, model.organizationKey )
                                )
                in
                    ( { model
                        | currentPage =
                            TransitioningTo
                                (ArticleEdit articleEditModel)
                        , route = newRoute
                      }
                    , cmd
                    )

            Route.NotFound ->
                ( { model | currentPage = Loaded NotFound }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NavigateTo route ->
            navigateTo route model
                |> Tuple.mapSecond
                    (\cmd ->
                        Cmd.batch <|
                            cmd
                                :: [ modifyUrl <|
                                        Route.routeToString route
                                   ]
                    )

        ArticleListMsg alMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (ArticleList articleListModel) ->
                            articleListModel

                        _ ->
                            ArticleList.initModel model.organizationKey

                ( articleListModel, articleListCmd ) =
                    ArticleList.update alMsg
                        currentPageModel
                        model.organizationKey
                        model.nodeEnv
            in
                ( { model | currentPage = Loaded (ArticleList articleListModel) }
                , Cmd.map ArticleListMsg articleListCmd
                )

        ArticleCreateMsg caMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (ArticleCreate articleCreateModel) ->
                            articleCreateModel

                        _ ->
                            ArticleCreate.initModel

                ( articleCreateModel, createArticleCmd ) =
                    ArticleCreate.update caMsg
                        currentPageModel
                        model.nodeEnv
                        model.organizationKey
            in
                ( { model | currentPage = Loaded (ArticleCreate articleCreateModel) }
                , Cmd.map ArticleCreateMsg createArticleCmd
                )

        ArticleEditMsg aeMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (ArticleEdit articleEditModel) ->
                            articleEditModel

                        _ ->
                            ArticleEdit.initModel "0"

                ( articleEditModel, articleEditCmd ) =
                    ArticleEdit.update aeMsg
                        currentPageModel
                        model.nodeEnv
                        model.organizationKey
            in
                ( { model | currentPage = TransitioningTo (ArticleEdit articleEditModel) }
                , Cmd.map ArticleEditMsg articleEditCmd
                )

        ArticleCategoriesLoaded (Ok categoriesList) ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (ArticleCreate articleCreateModel) ->
                            articleCreateModel

                        _ ->
                            ArticleCreate.initModel
            in
                ( { model
                    | currentPage =
                        Loaded
                            (ArticleCreate
                                { currentPageModel | categories = categoriesList }
                            )
                  }
                , Cmd.none
                )

        ArticleCategoriesLoaded (Err error) ->
            ( { model | error = Just (toString error) }, Cmd.none )

        UrlCreateMsg cuMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (UrlCreate urlCreateModel) ->
                            urlCreateModel

                        _ ->
                            UrlCreate.initModel

                ( createUrlModel, createUrlCmds ) =
                    UrlCreate.update cuMsg
                        currentPageModel
                        model.nodeEnv
                        model.organizationKey
            in
                ( { model | currentPage = Loaded (UrlCreate createUrlModel) }
                , Cmd.map UrlCreateMsg createUrlCmds
                )

        UrlEditMsg ueMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (UrlEdit urlEditModel) ->
                            urlEditModel

                        _ ->
                            UrlEdit.initModel "0"

                ( urlEditModel, urlEditCmd ) =
                    UrlEdit.update ueMsg currentPageModel model.nodeEnv model.organizationKey
            in
                ( { model | currentPage = Loaded (UrlEdit urlEditModel) }
                , Cmd.map UrlEditMsg urlEditCmd
                )

        UrlListMsg ulMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (UrlList urlListModel) ->
                            urlListModel

                        _ ->
                            UrlList.initModel model.organizationKey

                ( urlListModel, urlListCmds ) =
                    UrlList.update ulMsg currentPageModel model.nodeEnv model.organizationKey
            in
                ( { model | currentPage = Loaded (UrlList urlListModel) }
                , Cmd.map UrlListMsg urlListCmds
                )

        UrlsLoaded (Ok urlsList) ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (UrlList urlListModel) ->
                            urlListModel

                        _ ->
                            UrlList.initModel model.organizationKey
            in
                ( { model
                    | currentPage =
                        Loaded
                            (UrlList
                                { currentPageModel
                                    | urls = urlsList
                                }
                            )
                  }
                , Cmd.none
                )

        UrlsLoaded (Err error) ->
            ( model, Cmd.none )

        TicketListMsg tlMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (TicketList ticketListModel) ->
                            ticketListModel

                        _ ->
                            TicketList.initModel

                ( ticketListModel, ticketListCmds ) =
                    TicketList.update tlMsg
                        currentPageModel
                        model.nodeEnv
                        model.organizationKey
            in
                ( { model | currentPage = Loaded (TicketList ticketListModel) }
                , Cmd.map TicketListMsg ticketListCmds
                )

        CategoryListMsg clMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (CategoryList categoryListModel) ->
                            categoryListModel

                        _ ->
                            CategoryList.initModel model.organizationKey

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
                            categoryListModel

                        _ ->
                            CategoryList.initModel model.organizationKey
            in
                ( { model
                    | currentPage =
                        Loaded
                            (CategoryList
                                { currentPageModel | categories = categoriesList }
                            )
                  }
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
                    CategoryCreate.update ccMsg
                        currentPageModel
                        model.nodeEnv
                        model.organizationKey
            in
                ( { model
                    | currentPage = Loaded (CategoryCreate categoryCreateModel)
                  }
                , Cmd.map CategoryCreateMsg categoryCreateCmd
                )

        SettingsMsg settingsMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (Settings settingsPageModel) ->
                            settingsPageModel

                        _ ->
                            Settings.initModel model.organizationKey

                ( settingsModel, settingsCmd ) =
                    Settings.update settingsMsg currentPageModel
            in
                ( { model
                    | currentPage = Loaded (Settings settingsModel)
                  }
                , Cmd.map SettingsMsg settingsCmd
                )

        OnLocationChange location ->
            setRoute location model

        SignOut ->
            ( model, Http.send SignedOut (logoutRequest model.nodeEnv) )

        SignedOut _ ->
            ( model, load (Admin.Request.Helper.baseUrl model.nodeEnv) )


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

        ArticleEdit articleEditModel ->
            adminLayout model
                (Html.map ArticleEditMsg
                    (ArticleEdit.view articleEditModel)
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

        Settings settingsModel ->
            adminLayout model
                (Html.map SettingsMsg
                    (Settings.view settingsModel)
                )

        TicketList ticketListModel ->
            adminLayout model
                (Html.map TicketListMsg
                    (TicketList.view ticketListModel)
                )

        UrlEdit urlEditModel ->
            adminLayout model
                (Html.map UrlEditMsg
                    (UrlEdit.view urlEditModel)
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
                        , ( "active"
                          , (model.route
                                == (Route.ArticleList
                                        model.organizationKey
                                   )
                            )
                                || (model.route == Route.ArticleCreate model.organizationKey)
                          )
                        ]
                    , onClick <| NavigateTo (Route.ArticleList model.organizationKey)
                    ]
                    [ text "Articles" ]
                ]
            , li [ class "nav-item" ]
                [ Html.a
                    [ classList
                        [ ( "nav-link", True )
                        , ( "active"
                          , (model.route == (Route.UrlList model.organizationKey))
                                || (model.route == Route.UrlCreate model.organizationKey)
                          )
                        ]
                    , onClick <| NavigateTo (Route.UrlList model.organizationKey)
                    ]
                    [ text "URL" ]
                ]
            , li [ class "nav-item" ]
                [ Html.a
                    [ classList
                        [ ( "nav-link", True )
                        , ( "active"
                          , (model.route == (Route.CategoryList model.organizationKey))
                                || (model.route == Route.CategoryCreate model.organizationKey)
                          )
                        ]
                    , onClick <| NavigateTo (Route.CategoryList model.organizationKey)
                    ]
                    [ text "Category" ]
                ]
            , li [ class "nav-item" ]
                [ Html.a
                    [ classList
                        [ ( "nav-link", True )
                        , ( "active", (model.route == (Route.TicketList model.organizationKey)) )
                        ]
                    , onClick <| NavigateTo (Route.TicketList model.organizationKey)
                    ]
                    [ text "Ticket" ]
                ]
            , li [ class "nav-item" ]
                [ Html.a
                    [ classList
                        [ ( "nav-link", True )
                        , ( "active", (model.route == (Route.Settings model.organizationKey)) )
                        ]
                    , onClick <| NavigateTo (Route.Settings model.organizationKey)
                    ]
                    [ text "Settings" ]
                ]
            ]
        , ul [ class "navbar-nav ml-auto" ]
            [ li [ class "nav-item " ]
                [ Html.a [ class "nav-link", onClick SignOut ]
                    [ text "Logout" ]
                ]
            ]
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
