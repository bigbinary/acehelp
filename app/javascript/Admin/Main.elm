module Main exposing (..)

import Admin.Data.Organization exposing (OrganizationId)
import Admin.Request.Helper exposing (ApiKey, NodeEnv, logoutRequest)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Navigation exposing (..)
import Page.Session.Login as Login
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
import UrlParser as Url exposing (..)
import Admin.Request.Helper exposing (NodeEnv, ApiKey, logoutRequest)
import Route
import Task exposing (Task)
import Page.Helpers exposing (..)
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
    | Login Login.Model
    | NotFound
    | Blank


type PageState
    = Loaded Page
    | TransitioningFrom Page


type alias Model =
    { currentPage : PageState
    , route : Route.Route
    , nodeEnv : NodeEnv
    , organizationKey : ApiKey
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
    | TicketListMsg TicketList.Msg
    | FeedbackListMsg FeedbackList.Msg
    | FeedbackShowMsg FeedbackShow.Msg
    | TeamListMsg TeamList.Msg
    | TeamCreateMsg TeamMemberCreate.Msg
    | TicketEditMsg TicketEdit.Msg
    | SettingsMsg Settings.Msg
    | OnLocationChange Navigation.Location
    | LoginMsg Login.Msg
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

        TransitioningFrom page ->
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
        transitionFrom page msg =
            Tuple.mapFirst
                (\pageModel ->
                    { model
                        | currentPage =
                            TransitioningFrom (page pageModel)
                        , route = newRoute
                    }
                )
                >> Tuple.mapSecond
                    (Cmd.map msg)

        newTransitionFrom msg =
            Tuple.mapFirst
                (\pageModel ->
                    { model
                        | currentPage = TransitioningFrom (getPage model.currentPage)
                        , route = newRoute
                    }
                )
                >> Tuple.mapSecond
                    (pageCmdsToCmd msg model.nodeEnv model.organizationKey)
    in
        case newRoute of
            Route.ArticleList organizationKey ->
                ArticleList.init
                    |> newTransitionFrom ArticleListMsg

            Route.ArticleCreate organizationKey ->
                ArticleCreate.init
                    |> newTransitionFrom ArticleCreateMsg

            Route.CategoryList organizationKey ->
                CategoryList.init
                    |> newTransitionFrom CategoryListMsg

            Route.CategoryCreate organizationKey ->
                CategoryCreate.init
                    |> newTransitionFrom CategoryCreateMsg

            Route.UrlList organizationKey ->
                UrlList.init
                    |> newTransitionFrom UrlListMsg

            Route.UrlCreate organizationKey ->
                UrlCreate.init
                    |> newTransitionFrom UrlCreateMsg

            Route.TicketList organizationKey ->
                TicketList.init model.nodeEnv model.organizationKey
                    |> transitionFrom TicketList TicketListMsg

            Route.UrlEdit organizationKey urlId ->
                UrlEdit.init urlId
                    |> newTransitionFrom UrlEditMsg

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
                            TransitioningFrom
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
                            TransitioningFrom
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
                            TransitioningFrom
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
                            TransitioningFrom
                                (TicketEdit ticketEditModel)
                        , route = newRoute
                      }
                    , cmd
                    )

            Route.TeamMemberCreate organizationKey ->
                (TeamMemberCreate.init)
                    |> transitionFrom TeamMemberCreate TeamCreateMsg

            Route.Settings organizationKey ->
                Settings.init model.organizationKey
                    |> transitionFrom Settings SettingsMsg

            Route.Dashboard ->
                ( { model | currentPage = Loaded Dashboard }, Cmd.none )

            Route.ArticleEdit organizationKey articleId ->
                ArticleEdit.init articleId
                    |> newTransitionFrom ArticleEditMsg

            Route.CategoryEdit categoryId ->
                CategoryEdit.init categoryId
                    |> newTransitionFrom CategoryEditMsg

            Route.SignUp ->
                let
                    ( signUpModel, signUpCmd ) =
                        SignUp.init
                in
                    ( { model
                        | currentPage =
                            TransitioningFrom
                                (SignUp signUpModel)
                        , route = newRoute
                      }
                    , Cmd.map SignUpMsg signUpCmd
                    )

            Route.OrganizationCreate ->
                (OrganizationCreate.init model.userId)
                    |> transitionFrom OrganizationCreate OrganizationCreateMsg

            Route.Login ->
                Login.init
                    |> transitionFrom Login LoginMsg

            Route.NotFound ->
                ( { model
                    | currentPage =
                        TransitioningFrom NotFound
                    , route = newRoute
                  }
                , Cmd.none
                )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        runCmds =
            flip (flip pageCmdsToCmd model.nodeEnv) model.organizationKey
    in
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
                        case getPage model.currentPage of
                            ArticleList articleListModel ->
                                articleListModel

                            _ ->
                                ArticleList.initModel

                    ( newModel, cmds ) =
                        ArticleList.update alMsg
                            currentPageModel
                in
                    ( { model | currentPage = Loaded (ArticleList newModel) }
                    , runCmds ArticleListMsg cmds
                    )

            ArticleCreateMsg caMsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            ArticleCreate articleCreateModel ->
                                articleCreateModel

                            _ ->
                                ArticleCreate.initModel

                    ( newModel, cmds ) =
                        ArticleCreate.update caMsg
                            currentPageModel
                in
                    ( { model | currentPage = Loaded (ArticleCreate newModel) }
                    , runCmds ArticleCreateMsg cmds
                    )

            ArticleEditMsg aeMsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            ArticleEdit articleEditModel ->
                                articleEditModel

                            _ ->
                                ArticleEdit.initModel "0"

                    ( newModel, cmds ) =
                        ArticleEdit.update aeMsg
                            currentPageModel
                in
                    ( { model | currentPage = Loaded (ArticleEdit newModel) }
                    , runCmds ArticleEditMsg cmds
                    )

            UrlCreateMsg cuMsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            UrlCreate urlCreateModel ->
                                urlCreateModel

                            _ ->
                                UrlCreate.initModel

                    ( newModel, cmds ) =
                        UrlCreate.update cuMsg
                            currentPageModel
                in
                    ( { model | currentPage = Loaded (UrlCreate newModel) }
                    , runCmds UrlCreateMsg cmds
                    )

            UrlEditMsg ueMsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            UrlEdit urlEditModel ->
                                urlEditModel

                            _ ->
                                UrlEdit.initModel "0"

                    ( newModel, cmds ) =
                        UrlEdit.update ueMsg currentPageModel
                in
                    ( { model | currentPage = Loaded (UrlEdit newModel) }
                    , runCmds UrlEditMsg cmds
                    )

            UrlListMsg ulMsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            UrlList urlListModel ->
                                urlListModel

                            _ ->
                                UrlList.initModel

                    ( newModel, cmds ) =
                        UrlList.update ulMsg currentPageModel
                in
                    ( { model | currentPage = Loaded (UrlList newModel) }
                    , runCmds UrlListMsg cmds
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
                        case getPage model.currentPage of
                            CategoryList categoryListModel ->
                                categoryListModel

                            _ ->
                                CategoryList.initModel

                    ( newModel, cmds ) =
                        CategoryList.update
                            clMsg
                            currentPageModel
                in
                    ( { model | currentPage = Loaded (CategoryList newModel) }
                    , runCmds CategoryListMsg cmds
                    )

            CategoryCreateMsg ccMsg ->
                let
                    currentPageModel =
                        case model.currentPage of
                            Loaded (CategoryCreate categoryCreateModel) ->
                                categoryCreateModel

                            _ ->
                                CategoryCreate.initModel

                    ( newModel, cmds ) =
                        CategoryCreate.update ccMsg
                            currentPageModel
                in
                    ( { model
                        | currentPage = Loaded (CategoryCreate newModel)
                      }
                    , runCmds CategoryCreateMsg cmds
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
                    ( { model | currentPage = TransitioningFrom (FeedbackShow feedbackShowModel) }
                    , Cmd.map FeedbackShowMsg feedbackShowCmd
                    )

            CategoryEditMsg ctMsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            CategoryEdit categoryEditModel ->
                                categoryEditModel

                            _ ->
                                CategoryEdit.initModel "0"

                    ( newModel, cmds ) =
                        CategoryEdit.update ctMsg
                            currentPageModel
                in
                    ( { model | currentPage = Loaded (CategoryEdit newModel) }
                    , runCmds CategoryEditMsg cmds
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
                    ( { model | currentPage = TransitioningFrom (TicketEdit ticketEditModel) }
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

            LoginMsg loginMsg ->
                ( model, Cmd.none )

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

        Login loginModel ->
            Html.map LoginMsg (Login.view loginModel)

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
