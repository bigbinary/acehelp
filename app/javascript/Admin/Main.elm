module Main exposing (..)

import Admin.Data.Category exposing (Category)
import Admin.Data.Organization exposing (OrganizationId)
import Admin.Data.Url exposing (UrlData)
import Admin.Request.Helper exposing (ApiKey, NodeEnv, logoutRequest)
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Navigation exposing (..)
import Page.Article.Create as ArticleCreate
import Page.Article.Edit as ArticleEdit
import Page.Article.List as ArticleList
import Page.Category.Create as CategoryCreate
import Page.Category.Edit as CategoryEdit
import Page.Category.List as CategoryList
import Page.Ticket.List as TicketList
import Page.Team.List as TeamList
import Page.Feedback.List as FeedbackList
import Page.Feedback.Show as FeedbackShow
import Page.Category.Create as CategoryCreate
import Page.Team.Create as TeamMemberCreate
import Page.Settings as Settings
import Page.Organization.Create as OrganizationCreate
import Page.Session.SignUp as SignUp
import Page.Errors as Errors
import Admin.Data.Organization exposing (OrganizationId)
import Admin.Data.Category exposing (Category)
import Admin.Data.User exposing (..)
import Admin.Data.Url exposing (UrlData)
import UrlParser as Url exposing (..)
import Admin.Request.Helper exposing (NodeEnv, ApiKey, logoutRequest)
import Route
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient
import Page.Ticket.List as TicketList
import Page.Ticket.Edit as TicketEdit
import Page.Url.Create as UrlCreate
import Page.Url.Edit as UrlEdit
import Page.Url.List as UrlList
import Reader exposing (Reader)
import Route
import Task exposing (Task)
import UrlParser as Url exposing (..)


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
    | CategoryEdit CategoryEdit.Model
    | UrlList UrlList.Model
    | UrlCreate UrlCreate.Model
    | UrlEdit UrlEdit.Model
    | Settings Settings.Model
    | OrganizationCreate OrganizationCreate.Model
    | TicketList TicketList.Model
    | TicketEdit TicketEdit.Model
    | FeedbackList FeedbackList.Model
    | FeedbackShow FeedbackShow.Model
    | TeamList TeamList.Model
    | TeamMemberCreate TeamMemberCreate.Model
    | SignUp SignUp.Model
    | Dashboard
    | Blank
    | NotFound


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
        ( pageModel, pageCmd )



-- MSG


type Msg
    = NavigateTo Route.Route
    | ArticleListMsg ArticleList.Msg
    | ArticleCreateMsg ArticleCreate.Msg
    | ArticleEditMsg ArticleEdit.Msg
    | UrlCreateMsg UrlCreate.Msg
    | UrlEditMsg UrlEdit.Msg
    | UrlListMsg UrlList.Msg
    | CategoryListMsg CategoryList.Msg
    | CategoryCreateMsg CategoryCreate.Msg
    | CategoryEditMsg CategoryEdit.Msg
    | CategoriesLoaded (Result GQLClient.Error (List Category))
    | TicketListMsg TicketList.Msg
    | FeedbackListMsg FeedbackList.Msg
    | FeedbackShowMsg FeedbackShow.Msg
    | TeamListMsg TeamList.Msg
    | TeamCreateMsg TeamMemberCreate.Msg
    | TicketEditMsg TicketEdit.Msg
    | SettingsMsg Settings.Msg
    | OnLocationChange Navigation.Location
    | SignOut
    | SignedOut (Result Http.Error String)
    | SignUpMsg SignUp.Msg
    | OrganizationCreateMsg OrganizationCreate.Msg



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
                    { model
                        | currentPage =
                            TransitioningTo (page pageModel)
                        , route = newRoute
                    }
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
                                (Reader.run articleListRequest
                                    ( model.nodeEnv
                                    , organizationKey
                                    )
                                )
                in
                    ( { model
                        | currentPage =
                            TransitioningTo
                                (ArticleList articleListModel)
                        , route = newRoute
                        , organizationKey = organizationKey
                      }
                    , cmd
                    )

            Route.ArticleCreate organizationKey ->
                let
                    ( articleCreateModel, categoriesRequest, urlsRequest ) =
                        ArticleCreate.init

                    cmdCategoriesRequest =
                        Cmd.map ArticleCreateMsg <|
                            Task.attempt ArticleCreate.CategoriesLoaded
                                (Reader.run categoriesRequest
                                    ( model.nodeEnv
                                    , model.organizationKey
                                    )
                                )

                    cmdUrlsRequest =
                        Cmd.map ArticleCreateMsg <|
                            Task.attempt ArticleCreate.UrlsLoaded
                                (Reader.run urlsRequest
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
                    , Cmd.batch [ cmdCategoriesRequest, cmdUrlsRequest ]
                    )

            Route.CategoryList organizationKey ->
                let
                    ( categoryListModel, categoriesRequest ) =
                        CategoryList.init organizationKey

                    cmd =
                        Task.attempt CategoriesLoaded
                            (Reader.run
                                categoriesRequest
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
                CategoryCreate.init
                    |> transitionTo CategoryCreate CategoryCreateMsg

            Route.UrlList organizationKey ->
                let
                    ( urlListModel, urlListCmd ) =
                        UrlList.init organizationKey

                    cmd =
                        Cmd.map UrlListMsg <| Task.attempt UrlList.UrlLoaded (Reader.run urlListCmd ( model.nodeEnv, model.organizationKey ))
                in
                    ( { model
                        | currentPage = TransitioningTo (UrlList urlListModel)
                        , route = newRoute
                      }
                    , cmd
                    )

            Route.UrlCreate organizationKey ->
                UrlCreate.init
                    |> transitionTo UrlCreate UrlCreateMsg

            Route.TicketList organizationKey ->
                TicketList.init model.nodeEnv model.organizationKey
                    |> transitionTo TicketList TicketListMsg

            Route.UrlEdit organizationKey urlId ->
                let
                    ( urlEditModel, urlEditCmd ) =
                        UrlEdit.init urlId

                    cmd =
                        Cmd.map UrlEditMsg <| Task.attempt UrlEdit.UrlLoaded (Reader.run urlEditCmd ( model.nodeEnv, model.organizationKey ))
                in
                    ( { model
                        | currentPage = TransitioningTo (UrlEdit urlEditModel)
                        , route = newRoute
                      }
                    , cmd
                    )

            Route.FeedbackList organizationKey ->
                let
                    ( feedbackListModel, feedbackListRequest ) =
                        FeedbackList.init organizationKey

                    cmd =
                        Cmd.map FeedbackListMsg <|
                            Task.attempt
                                FeedbackList.FeedbackListLoaded
                                (Reader.run feedbackListRequest
                                    ( model.nodeEnv
                                    , model.organizationKey
                                    , "open"
                                    )
                                )
                in
                    ( { model
                        | currentPage =
                            TransitioningTo
                                (FeedbackList feedbackListModel)
                        , route = newRoute
                      }
                    , cmd
                    )

            Route.FeedbackShow organizationKey feedbackId ->
                let
                    ( feedbackShowModel, feedbackShowRequest ) =
                        FeedbackShow.init feedbackId

                    cmd =
                        Cmd.map FeedbackShowMsg <|
                            Task.attempt
                                FeedbackShow.FeedbackLoaded
                                (Reader.run feedbackShowRequest
                                    ( model.nodeEnv, model.organizationKey )
                                )
                in
                    ( { model
                        | currentPage =
                            TransitioningTo
                                (FeedbackShow feedbackShowModel)
                        , route = newRoute
                      }
                    , cmd
                    )

            Route.TeamList organizationKey ->
                let
                    ( teamListModel, teamListRequest ) =
                        TeamList.init organizationKey

                    cmd =
                        Cmd.map TeamListMsg <|
                            Task.attempt
                                TeamList.TeamListLoaded
                                (Reader.run (teamListRequest)
                                    ( model.nodeEnv
                                    , model.organizationKey
                                    )
                                )
                in
                    ( { model
                        | currentPage =
                            TransitioningTo
                                (TeamList teamListModel)
                        , route = newRoute
                      }
                    , cmd
                    )

            Route.TicketEdit organizationKey ticketId ->
                let
                    ( ticketEditModel, ticketEditRequest ) =
                        TicketEdit.init ticketId

                    cmd =
                        Cmd.map TicketEditMsg <|
                            Task.attempt
                                TicketEdit.TicketLoaded
                                (Reader.run ticketEditRequest
                                    ( model.nodeEnv, model.organizationKey )
                                )
                in
                    ( { model
                        | currentPage =
                            TransitioningTo
                                (TicketEdit ticketEditModel)
                        , route = newRoute
                      }
                    , cmd
                    )

            Route.TeamMemberCreate organizationKey ->
                (TeamMemberCreate.init)
                    |> transitionTo TeamMemberCreate TeamCreateMsg

            Route.Settings organizationKey ->
                Settings.init model.organizationKey
                    |> transitionTo Settings SettingsMsg

            Route.Dashboard ->
                ( { model | currentPage = Loaded Dashboard }, Cmd.none )

            Route.ArticleEdit organizationKey articleId ->
                let
                    ( articleEditModel, articleEditTask, articleCategoriesTask, articleUrlsTask ) =
                        ArticleEdit.init articleId

                    cmdArticle =
                        Cmd.map ArticleEditMsg <|
                            Task.attempt
                                (ArticleEdit.ArticleLoaded)
                                (Reader.run (articleEditTask)
                                    ( model.nodeEnv, model.organizationKey )
                                )

                    cmdCategories =
                        Cmd.map ArticleEditMsg <|
                            Task.attempt
                                (ArticleEdit.CategoriesLoaded)
                                (Reader.run (articleCategoriesTask)
                                    ( model.nodeEnv, model.organizationKey )
                                )

                    cmdUrls =
                        Cmd.map ArticleEditMsg <|
                            Task.attempt
                                (ArticleEdit.UrlsLoaded)
                                (Reader.run (articleUrlsTask)
                                    ( model.nodeEnv, model.organizationKey )
                                )
                in
                    ( { model
                        | currentPage =
                            TransitioningTo
                                (ArticleEdit articleEditModel)
                        , route = newRoute
                      }
                    , Cmd.batch [ cmdArticle, cmdCategories, cmdUrls ]
                    )

            Route.CategoryEdit categoryId ->
                let
                    ( categoryEditModel, categoryEditCmd ) =
                        CategoryEdit.init categoryId

                    cmd =
                        Cmd.map CategoryEditMsg <|
                            Task.attempt
                                CategoryEdit.CategoryLoaded
                                (Reader.run categoryEditCmd
                                    ( model.nodeEnv, model.organizationKey )
                                )
                in
                    ( { model
                        | currentPage =
                            TransitioningTo
                                (CategoryEdit categoryEditModel)
                        , route = newRoute
                      }
                    , cmd
                    )

            Route.SignUp ->
                let
                    ( signUpModel, signUpCmd ) =
                        SignUp.init
                in
                    ( { model
                        | currentPage =
                            TransitioningTo
                                (SignUp signUpModel)
                        , route = newRoute
                      }
                    , Cmd.map SignUpMsg signUpCmd
                    )

            Route.OrganizationCreate ->
                (OrganizationCreate.init model.userId)
                    |> transitionTo OrganizationCreate OrganizationCreateMsg

            Route.NotFound ->
                ( { model
                    | currentPage =
                        TransitioningTo NotFound
                    , route = newRoute
                  }
                , Cmd.none
                )


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
                    case getPage model.currentPage of
                        ArticleEdit articleEditModel ->
                            articleEditModel

                        _ ->
                            ArticleEdit.initModel "0"

                ( articleEditModel, articleEditCmd ) =
                    ArticleEdit.update aeMsg
                        currentPageModel
                        model.nodeEnv
                        model.organizationKey
            in
                ( { model | currentPage = Loaded (ArticleEdit articleEditModel) }
                , Cmd.map ArticleEditMsg articleEditCmd
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

        TicketListMsg tlMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (TicketList ticketListModel) ->
                            ticketListModel

                        _ ->
                            TicketList.initModel model.organizationKey

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
                    CategoryList.update
                        clMsg
                        currentPageModel
                        model.nodeEnv
                        model.organizationKey
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

        FeedbackListMsg flmsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (FeedbackList feedbackListModel) ->
                            feedbackListModel

                        _ ->
                            FeedbackList.initModel model.organizationKey

                ( feedbackListModel, feedbackListCmd ) =
                    FeedbackList.update flmsg
                        currentPageModel
                        model.organizationKey
                        model.nodeEnv
            in
                ( { model | currentPage = Loaded (FeedbackList feedbackListModel) }
                , Cmd.map FeedbackListMsg feedbackListCmd
                )

        FeedbackShowMsg fsMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (FeedbackShow feedbackShowModel) ->
                            feedbackShowModel

                        _ ->
                            FeedbackShow.initModel "0"

                ( feedbackShowModel, feedbackShowCmd ) =
                    FeedbackShow.update fsMsg
                        currentPageModel
                        model.nodeEnv
                        model.organizationKey
            in
                ( { model | currentPage = TransitioningTo (FeedbackShow feedbackShowModel) }
                , Cmd.map FeedbackShowMsg feedbackShowCmd
                )

        CategoryEditMsg ctMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (CategoryEdit categoryEditModel) ->
                            categoryEditModel

                        _ ->
                            CategoryEdit.initModel "0"

                ( categoryEditModel, categoryEditCmd ) =
                    CategoryEdit.update ctMsg
                        currentPageModel
                        model.nodeEnv
                        model.organizationKey
            in
                ( { model | currentPage = Loaded (CategoryEdit categoryEditModel) }
                , Cmd.map CategoryEditMsg categoryEditCmd
                )

        TeamListMsg tlmsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (TeamList teamListModel) ->
                            teamListModel

                        _ ->
                            TeamList.initModel model.organizationKey

                ( teamListModel, teamListCmd ) =
                    TeamList.update tlmsg
                        currentPageModel
                        model.organizationKey
                        model.nodeEnv
            in
                ( { model | currentPage = Loaded (TeamList teamListModel) }
                , Cmd.map TeamListMsg teamListCmd
                )

        TeamCreateMsg tcmsg ->
            let
                currentPageModel =
                    case getPage model.currentPage of
                        TeamMemberCreate teamCreateModel ->
                            teamCreateModel

                        _ ->
                            TeamMemberCreate.initModel

                ( createTeamModel, createTeamCmds ) =
                    TeamMemberCreate.update tcmsg
                        currentPageModel
                        model.nodeEnv
                        model.organizationKey
            in
                ( { model | currentPage = Loaded (TeamMemberCreate createTeamModel) }
                , Cmd.map TeamCreateMsg createTeamCmds
                )

        TicketEditMsg teMsg ->
            let
                currentPageModel =
                    case getPage model.currentPage of
                        TicketEdit ticketEditModel ->
                            ticketEditModel

                        _ ->
                            TicketEdit.initModel "0"

                ( ticketEditModel, ticketEditCmd ) =
                    TicketEdit.update teMsg
                        currentPageModel
                        model.nodeEnv
                        model.organizationKey
            in
                ( { model | currentPage = TransitioningTo (TicketEdit ticketEditModel) }
                , Cmd.map TicketEditMsg ticketEditCmd
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

        OrganizationCreateMsg oCMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (OrganizationCreate orgCreateModel) ->
                            orgCreateModel

                        _ ->
                            OrganizationCreate.initModel model.userId

                ( createOrgModel, createOrgCmds ) =
                    OrganizationCreate.update oCMsg currentPageModel model.nodeEnv
            in
                ( { model | currentPage = Loaded (OrganizationCreate createOrgModel) }
                , Cmd.map OrganizationCreateMsg createOrgCmds
                )

        SignUpMsg suMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Loaded (SignUp signUpModel) ->
                            signUpModel

                        _ ->
                            SignUp.initModel

                ( signUpModel, signUpCmds ) =
                    SignUp.update suMsg currentPageModel model.nodeEnv model.organizationKey
            in
                ( { model | currentPage = Loaded (SignUp signUpModel) }
                , Cmd.map SignUpMsg signUpCmds
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
        getOrganizationId org


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
    case getPage model.currentPage of
        ArticleEdit articleEditModel ->
            Sub.map ArticleEditMsg <| ArticleEdit.subscriptions articleEditModel

        _ ->
            Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    case getPage model.currentPage of
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

        CategoryEdit categoryEditModel ->
            adminLayout model
                (Html.map CategoryEditMsg
                    (CategoryEdit.view categoryEditModel)
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

        FeedbackList feedbackListModel ->
            adminLayout model
                (Html.map FeedbackListMsg
                    (FeedbackList.view feedbackListModel)
                )

        FeedbackShow feedbackShowModel ->
            adminLayout model
                (Html.map FeedbackShowMsg
                    (FeedbackShow.view feedbackShowModel)
                )

        TeamList teamListModel ->
            adminLayout model
                (Html.map TeamListMsg
                    (TeamList.view teamListModel)
                )

        TeamMemberCreate teamMemberCreateModel ->
            adminLayout model
                (Html.map TeamCreateMsg
                    (TeamMemberCreate.view teamMemberCreateModel)
                )

        TicketEdit ticketEditModel ->
            adminLayout model
                (Html.map TicketEditMsg
                    (TicketEdit.view ticketEditModel)
                )

        Dashboard ->
            div [] [ text "Dashboard" ]

        OrganizationCreate orgCreateModel ->
            adminLayout model
                (Html.map OrganizationCreateMsg
                    (OrganizationCreate.view orgCreateModel)
                )

        SignUp signupModel ->
            (Html.map SignUpMsg
                (SignUp.view signupModel)
            )

        NotFound ->
            Errors.notFound

        Blank ->
            div [] [ text "Blank" ]


adminLayout : Model -> Html Msg -> Html Msg
adminLayout model page =
    div []
        [ adminHeader model
        , div [ class "container main-wrapper" ] [ page ]
        ]


adminHeader : Model -> Html Msg
adminHeader model =
    nav [ class "header navbar navbar-dark bg-primary navbar-expand flex-column flex-md-row" ]
        [ div [ class "container" ]
            [ ul
                [ class "navbar-nav mr-auto mt-2 mt-lg-0 " ]
                [ li [ class "nav-item" ]
                    [ Html.a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active"
                              , (model.route
                                    == Route.ArticleList
                                        model.organizationKey
                                )
                                    || (model.route == Route.ArticleCreate model.organizationKey)
                              )
                            ]
                        , onClick <| NavigateTo (Route.ArticleList model.organizationKey)
                        ]
                        [ span [] [ text "Articles" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ Html.a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active"
                              , (model.route == Route.UrlList model.organizationKey)
                                    || (model.route == Route.UrlCreate model.organizationKey)
                              )
                            ]
                        , onClick <| NavigateTo (Route.UrlList model.organizationKey)
                        ]
                        [ span [] [ text "URL" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ Html.a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active"
                              , (model.route == Route.CategoryList model.organizationKey)
                                    || (model.route == Route.CategoryCreate model.organizationKey)
                              )
                            ]
                        , onClick <| NavigateTo (Route.CategoryList model.organizationKey)
                        ]
                        [ span [] [ text "Category" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ Html.a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active", model.route == Route.TicketList model.organizationKey )
                            ]
                        , onClick <| NavigateTo (Route.TicketList model.organizationKey)
                        ]
                        [ span [] [ text "Ticket" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ Html.a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active", model.route == Route.FeedbackList model.organizationKey )
                            ]
                        , onClick <| NavigateTo (Route.FeedbackList model.organizationKey)
                        ]
                        [ span [] [ text "Feedback" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ Html.a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active", (model.route == (Route.TeamList model.organizationKey)) )
                            ]
                        , onClick <| NavigateTo (Route.TeamList model.organizationKey)
                        ]
                        [ span [] [ text "Team" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ Html.a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active", (model.route == (Route.Settings model.organizationKey)) )
                            ]
                        , onClick <| NavigateTo (Route.Settings model.organizationKey)
                        ]
                        [ span [] [ text "Settings" ] ]
                    ]
                ]
            , ul [ class "navbar-nav ml-auto" ]
                [ li [ class "nav-item " ]
                    [ Html.a [ class "nav-link", onClick SignOut ]
                        [ text "Logout" ]
                    ]
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
