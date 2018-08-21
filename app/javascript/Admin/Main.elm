module Main exposing (..)

import Admin.Request.Helper exposing (ApiKey, NodeEnv, logoutRequest)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Navigation exposing (..)
import Page.Session.Login as Login
import Page.Session.ForgotPassword as ForgotPassword
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
import Admin.Request.Helper exposing (NodeEnv, ApiKey, logoutRequest)
import Route
import Admin.Data.ReaderCmd exposing (..)
import Page.Ticket.List as TicketList
import Page.Ticket.Edit as TicketEdit
import Page.Url.Create as UrlCreate
import Page.Url.Edit as UrlEdit
import Page.Url.List as UrlList
import Page.Common.View exposing (..)
import Route


-- MODEL


type alias Flags =
    { node_env : String
    , organization_key : String
    , organization_name : String
    , user_id : String
    , user_email : String
    , app_url : String
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
    | ForgotPassword ForgotPassword.Model
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
    , organizationName : String
    , userId : String
    , userEmail : String
    , appUrl : String
    , error : Maybe String
    }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        ( pageModel, readerCmd ) =
            setRoute location initModel

        initModel =
            { currentPage = Loaded Blank
            , route = Route.fromLocation location
            , nodeEnv = flags.node_env
            , organizationKey = flags.organization_key
            , organizationName = flags.organization_name
            , userId = flags.user_id
            , userEmail = flags.user_email
            , appUrl = flags.app_url
            , error = Nothing
            }
    in
        ( pageModel, readerCmd )



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
    | ForgotPasswordMsg ForgotPassword.Msg
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
        transitionTo page msg ( pageModel, pageCmds ) =
            case pageCmds of
                [] ->
                    ( { model
                        | currentPage = Loaded (page pageModel)
                        , route = newRoute
                      }
                    , Cmd.none
                    )

                _ ->
                    ( { model
                        | currentPage = TransitioningFrom (getPage model.currentPage)
                        , route = newRoute
                      }
                    , readerCmdToCmd model.nodeEnv model.organizationKey model.appUrl msg pageCmds
                    )
    in
        case newRoute of
            Route.ArticleList organizationKey ->
                ArticleList.init
                    |> transitionTo ArticleList ArticleListMsg

            Route.ArticleCreate organizationKey ->
                ArticleCreate.init
                    |> transitionTo ArticleCreate ArticleCreateMsg

            Route.CategoryList organizationKey ->
                CategoryList.init
                    |> transitionTo CategoryList CategoryListMsg

            Route.CategoryCreate organizationKey ->
                CategoryCreate.init
                    |> transitionTo CategoryCreate CategoryCreateMsg

            Route.UrlList organizationKey ->
                UrlList.init
                    |> transitionTo UrlList UrlListMsg

            Route.UrlCreate organizationKey ->
                UrlCreate.init
                    |> transitionTo UrlCreate UrlCreateMsg

            Route.TicketList organizationKey ->
                TicketList.init
                    |> transitionTo TicketList TicketListMsg

            Route.UrlEdit organizationKey urlId ->
                UrlEdit.init urlId
                    |> transitionTo UrlEdit UrlEditMsg

            Route.FeedbackList organizationKey ->
                FeedbackList.init
                    |> transitionTo FeedbackList FeedbackListMsg

            Route.FeedbackShow organizationKey feedbackId ->
                FeedbackShow.init feedbackId
                    |> transitionTo FeedbackShow FeedbackShowMsg

            Route.TeamList organizationKey ->
                TeamList.init
                    |> transitionTo TeamList TeamListMsg

            Route.TicketEdit organizationKey ticketId ->
                TicketEdit.init ticketId
                    |> transitionTo TicketEdit TicketEditMsg

            Route.TeamMemberCreate organizationKey ->
                TeamMemberCreate.init
                    |> transitionTo TeamMemberCreate TeamCreateMsg

            Route.Settings organizationKey ->
                Settings.init
                    |> transitionTo Settings SettingsMsg

            Route.Dashboard ->
                ( { model | currentPage = Loaded Dashboard }, Cmd.none )

            Route.ArticleEdit organizationKey articleId ->
                ArticleEdit.init articleId
                    |> transitionTo ArticleEdit ArticleEditMsg

            Route.CategoryEdit organizationKey categoryId ->
                CategoryEdit.init categoryId
                    |> transitionTo CategoryEdit CategoryEditMsg

            Route.SignUp ->
                SignUp.init
                    |> transitionTo SignUp SignUpMsg

            Route.OrganizationCreate ->
                (OrganizationCreate.init model.userId)
                    |> transitionTo OrganizationCreate OrganizationCreateMsg

            Route.Login ->
                Login.init
                    |> transitionTo Login LoginMsg

            Route.ForgotPassword ->
                ForgotPassword.init
                    |> transitionTo ForgotPassword ForgotPasswordMsg

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
        runReaderCmds =
            readerCmdToCmd model.nodeEnv model.organizationKey model.appUrl

        updateNavigation =
            flip update model
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
                        ArticleList.update alMsg currentPageModel
                in
                    case alMsg of
                        ArticleList.OnArticleCreateClick ->
                            updateNavigation (NavigateTo (Route.ArticleCreate model.organizationKey))

                        ArticleList.OnArticleEditClick articleId ->
                            updateNavigation (NavigateTo (Route.ArticleEdit model.organizationKey articleId))

                        _ ->
                            ( { model | currentPage = Loaded (ArticleList newModel) }
                            , runReaderCmds ArticleListMsg cmds
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
                    case caMsg of
                        ArticleCreate.SaveArticleResponse (Ok id) ->
                            updateNavigation (NavigateTo (Route.ArticleList model.organizationKey))

                        _ ->
                            ( { model | currentPage = Loaded (ArticleCreate newModel) }
                            , runReaderCmds ArticleCreateMsg cmds
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
                    , runReaderCmds ArticleEditMsg cmds
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
                    case cuMsg of
                        UrlCreate.SaveUrlResponse (Ok id) ->
                            updateNavigation (NavigateTo (Route.UrlList model.organizationKey))

                        _ ->
                            ( { model | currentPage = Loaded (UrlCreate newModel) }
                            , runReaderCmds UrlCreateMsg cmds
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
                    , runReaderCmds UrlEditMsg cmds
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
                    case ulMsg of
                        UrlList.OnUrlCreateClick ->
                            updateNavigation (NavigateTo (Route.UrlCreate model.organizationKey))

                        UrlList.OnUrlEditClick urlId ->
                            updateNavigation (NavigateTo (Route.UrlEdit model.organizationKey urlId))

                        _ ->
                            ( { model | currentPage = Loaded (UrlList newModel) }
                            , runReaderCmds UrlListMsg cmds
                            )

            TicketListMsg tlMsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            TicketList ticketListModel ->
                                ticketListModel

                            _ ->
                                TicketList.initModel

                    ( newModel, cmds ) =
                        TicketList.update tlMsg
                            currentPageModel
                in
                    case tlMsg of
                        TicketList.OnEditTicketClick ticketId ->
                            updateNavigation (NavigateTo (Route.TicketEdit model.organizationKey ticketId))

                        _ ->
                            ( { model | currentPage = Loaded (TicketList newModel) }
                            , runReaderCmds TicketListMsg cmds
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
                    case clMsg of
                        CategoryList.OnCreateCategoryClick ->
                            updateNavigation (NavigateTo (Route.CategoryCreate model.organizationKey))

                        CategoryList.OnEditCategoryClick categoryId ->
                            updateNavigation (NavigateTo (Route.CategoryEdit model.organizationKey categoryId))

                        _ ->
                            ( { model | currentPage = Loaded (CategoryList newModel) }
                            , runReaderCmds CategoryListMsg cmds
                            )

            CategoryCreateMsg ccMsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            CategoryCreate categoryCreateModel ->
                                categoryCreateModel

                            _ ->
                                CategoryCreate.initModel

                    ( newModel, cmds ) =
                        CategoryCreate.update ccMsg
                            currentPageModel
                in
                    case ccMsg of
                        CategoryCreate.SaveCategoryResponse (Ok id) ->
                            updateNavigation (NavigateTo (Route.CategoryList model.organizationKey))

                        _ ->
                            ( { model
                                | currentPage = Loaded (CategoryCreate newModel)
                              }
                            , runReaderCmds CategoryCreateMsg cmds
                            )

            FeedbackListMsg flMsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            FeedbackList feedbackListModel ->
                                feedbackListModel

                            _ ->
                                FeedbackList.initModel

                    ( newModel, cmds ) =
                        FeedbackList.update flMsg
                            currentPageModel
                in
                    case flMsg of
                        FeedbackList.OnFeedbackClick feedbackId ->
                            updateNavigation (NavigateTo (Route.FeedbackShow model.organizationKey feedbackId))

                        _ ->
                            ( { model | currentPage = Loaded (FeedbackList newModel) }
                            , runReaderCmds FeedbackListMsg cmds
                            )

            FeedbackShowMsg fsMsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            FeedbackShow feedbackShowModel ->
                                feedbackShowModel

                            _ ->
                                FeedbackShow.initModel "0"

                    ( newModel, cmds ) =
                        FeedbackShow.update fsMsg
                            currentPageModel
                in
                    ( { model | currentPage = Loaded (FeedbackShow newModel) }
                    , runReaderCmds FeedbackShowMsg cmds
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
                    , runReaderCmds CategoryEditMsg cmds
                    )

            TeamListMsg tlmsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            TeamList teamListModel ->
                                teamListModel

                            _ ->
                                TeamList.initModel

                    ( newModel, cmds ) =
                        TeamList.update tlmsg
                            currentPageModel
                in
                    case tlmsg of
                        TeamList.OnAddTeamMemberClick ->
                            updateNavigation (NavigateTo (Route.TeamMemberCreate model.organizationKey))

                        _ ->
                            ( { model | currentPage = Loaded (TeamList newModel) }
                            , runReaderCmds TeamListMsg cmds
                            )

            TeamCreateMsg tcmsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            TeamMemberCreate teamCreateModel ->
                                teamCreateModel

                            _ ->
                                TeamMemberCreate.initModel

                    ( newModel, cmds ) =
                        TeamMemberCreate.update tcmsg
                            currentPageModel
                in
                    ( { model | currentPage = Loaded (TeamMemberCreate newModel) }
                    , runReaderCmds TeamCreateMsg cmds
                    )

            TicketEditMsg teMsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            TicketEdit ticketEditModel ->
                                ticketEditModel

                            _ ->
                                TicketEdit.initModel "0"

                    ( newModel, cmds ) =
                        TicketEdit.update teMsg
                            currentPageModel
                in
                    ( { model | currentPage = Loaded (TicketEdit newModel) }
                    , runReaderCmds TicketEditMsg cmds
                    )

            SettingsMsg settingsMsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            Settings settingsPageModel ->
                                settingsPageModel

                            _ ->
                                Settings.initModel

                    ( newModel, cmds ) =
                        Settings.update settingsMsg currentPageModel
                in
                    ( { model
                        | currentPage = Loaded (Settings newModel)
                      }
                    , runReaderCmds SettingsMsg cmds
                    )

            OrganizationCreateMsg oCMsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            OrganizationCreate orgCreateModel ->
                                orgCreateModel

                            _ ->
                                OrganizationCreate.initModel model.userId

                    ( newModel, cmds ) =
                        OrganizationCreate.update oCMsg currentPageModel
                in
                    case oCMsg of
                        OrganizationCreate.SaveOrgResponse (Ok org) ->
                            let
                                ( updatedModel, updatedCmd ) =
                                    updateNavigation (NavigateTo (Route.ArticleList org.api_key))
                            in
                                ( { updatedModel
                                    | organizationKey = org.api_key
                                  }
                                , updatedCmd
                                )

                        _ ->
                            ( { model | currentPage = Loaded (OrganizationCreate newModel) }
                            , runReaderCmds OrganizationCreateMsg cmds
                            )

            SignUpMsg suMsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            SignUp signUpModel ->
                                signUpModel

                            _ ->
                                SignUp.initModel

                    ( newModel, cmds ) =
                        SignUp.update suMsg currentPageModel
                in
                    ( { model | currentPage = Loaded (SignUp newModel) }
                    , runReaderCmds SignUpMsg cmds
                    )

            LoginMsg loginMsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            Login signUpModel ->
                                signUpModel

                            _ ->
                                Login.initModel

                    ( newModel, cmds ) =
                        Login.update loginMsg currentPageModel
                in
                    ( { model | currentPage = Loaded (Login newModel) }
                    , runReaderCmds LoginMsg cmds
                    )

            ForgotPasswordMsg forgotPasswordMsg ->
                let
                    currentPageModel =
                        case getPage model.currentPage of
                            ForgotPassword forgotPasswordModel ->
                                forgotPasswordModel

                            _ ->
                                ForgotPassword.initModel

                    ( newModel, cmds ) =
                        ForgotPassword.update forgotPasswordMsg currentPageModel
                in
                    ( { model | currentPage = Loaded (ForgotPassword newModel) }
                    , runReaderCmds ForgotPasswordMsg cmds
                    )

            OnLocationChange location ->
                setRoute location model

            SignOut ->
                ( model, Http.send SignedOut (logoutRequest model.nodeEnv model.appUrl) )

            SignedOut _ ->
                ( model, load (Admin.Request.Helper.baseUrl model.nodeEnv model.appUrl) )



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
    let
        viewContent =
            case getPage model.currentPage of
                ArticleList articleListModel ->
                    Html.map ArticleListMsg
                        (ArticleList.view articleListModel)

                ArticleCreate articleCreateModel ->
                    Html.map ArticleCreateMsg
                        (ArticleCreate.view articleCreateModel)

                ArticleEdit articleEditModel ->
                    Html.map ArticleEditMsg
                        (ArticleEdit.view articleEditModel)

                UrlCreate urlCreateModel ->
                    Html.map UrlCreateMsg
                        (UrlCreate.view urlCreateModel)

                UrlList urlListModel ->
                    Html.map UrlListMsg
                        (UrlList.view urlListModel)

                CategoryList categoryListModel ->
                    Html.map CategoryListMsg
                        (CategoryList.view categoryListModel)

                CategoryCreate categoryCreateModel ->
                    Html.map CategoryCreateMsg
                        (CategoryCreate.view categoryCreateModel)

                CategoryEdit categoryEditModel ->
                    Html.map CategoryEditMsg
                        (CategoryEdit.view categoryEditModel)

                Settings settingsModel ->
                    Html.map SettingsMsg
                        (Settings.view model.nodeEnv model.organizationKey model.appUrl settingsModel)

                TicketList ticketListModel ->
                    Html.map TicketListMsg
                        (TicketList.view ticketListModel)

                UrlEdit urlEditModel ->
                    Html.map UrlEditMsg
                        (UrlEdit.view urlEditModel)

                FeedbackList feedbackListModel ->
                    Html.map FeedbackListMsg
                        (FeedbackList.view feedbackListModel)

                FeedbackShow feedbackShowModel ->
                    Html.map FeedbackShowMsg
                        (FeedbackShow.view feedbackShowModel)

                TeamList teamListModel ->
                    Html.map TeamListMsg
                        (TeamList.view teamListModel)

                TeamMemberCreate teamMemberCreateModel ->
                    Html.map TeamCreateMsg
                        (TeamMemberCreate.view teamMemberCreateModel)

                TicketEdit ticketEditModel ->
                    Html.map TicketEditMsg
                        (TicketEdit.view ticketEditModel)

                Dashboard ->
                    div [] [ text "Dashboard" ]

                OrganizationCreate orgCreateModel ->
                    Html.map OrganizationCreateMsg
                        (OrganizationCreate.view orgCreateModel)

                NotFound ->
                    Errors.notFound

                Blank ->
                    text ""

                SignUp _ ->
                    text ""

                Login _ ->
                    text ""

                ForgotPassword forgotPasswordModel ->
                    Html.map ForgotPasswordMsg
                        (ForgotPassword.view forgotPasswordModel)
    in
        case model.currentPage of
            TransitioningFrom (Login loginModel) ->
                Html.map LoginMsg (Login.view loginModel)

            Loaded (Login loginModel) ->
                Html.map LoginMsg (Login.view loginModel)

            TransitioningFrom (SignUp signupModel) ->
                (Html.map SignUpMsg
                    (SignUp.view signupModel)
                )

            Loaded (SignUp signupModel) ->
                (Html.map SignUpMsg
                    (SignUp.view signupModel)
                )

            TransitioningFrom (OrganizationCreate orgCreateModel) ->
                (Html.map OrganizationCreateMsg
                    (OrganizationCreate.view orgCreateModel)
                )

            Loaded (OrganizationCreate orgCreateModel) ->
                (Html.map OrganizationCreateMsg
                    (OrganizationCreate.view orgCreateModel)
                )

            TransitioningFrom _ ->
                adminLayout model [ viewContent, loadingIndicator ]

            Loaded _ ->
                adminLayout model [ viewContent ]


adminLayout : Model -> List (Html Msg) -> Html Msg
adminLayout model viewContent =
    div []
        [ adminHeader model
        , div [ class "container main-wrapper" ] viewContent
        ]


adminHeader : Model -> Html Msg
adminHeader model =
    nav [ class "header navbar navbar-dark bg-primary navbar-expand flex-column flex-md-row" ]
        [ div [ class "container" ]
            --[ span [ class "org-name" ] [ text model.organizationName ]
            [ ul
                [ class "navbar-nav mr-auto mt-2 mt-lg-0 " ]
                [ li [ class "nav-item" ]
                    [ Html.a
                        [ classList
                            [ ( "navbar-brand", True ) ]
                        ]
                        [ span [] [ text model.organizationName ] ]
                    ]
                , li [ class "nav-item" ]
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
