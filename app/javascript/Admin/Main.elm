module Main exposing
    ( Flags
    , Model
    , Msg(..)
    , Page(..)
    , PageState(..)
    , combineCmds
    , getPage
    , init
    , main
    , navigateTo
    , setRoute
    , subscriptions
    , update
    , view
    )

import Admin.Data.Common exposing (..)
import Admin.Data.Organization exposing (Organization)
import Admin.Data.ReaderCmd exposing (..)
import Admin.Request.Helper exposing (ApiKey, NodeEnv, logoutRequest)
import Admin.Request.Organization exposing (requestAllOrganizations)
import Admin.Views.Common exposing (..)
import Browser
import Browser.Navigation as Navigation exposing (..)
import Field exposing (..)
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Page.Article.Create as ArticleCreate
import Page.Article.Edit as ArticleEdit
import Page.Article.List as ArticleList
import Page.Category.Create as CategoryCreate
import Page.Category.Edit as CategoryEdit
import Page.Category.List as CategoryList
import Page.Errors as Errors
import Page.Feedback.List as FeedbackList
import Page.Feedback.Show as FeedbackShow
import Page.Organization.Create as OrganizationCreate
import Page.Session.ForgotPassword as ForgotPassword
import Page.Session.Login as Login
import Page.Session.SignUp as SignUp
import Page.Settings.Settings as Settings
import Page.Team.Create as TeamMemberCreate
import Page.Team.List as TeamList
import Page.Ticket.Edit as TicketEdit
import Page.Ticket.List as TicketList
import Page.Url.Create as UrlCreate
import Page.Url.Edit as UrlEdit
import Page.Url.List as UrlList
import Page.UserNotification as UserNotification
import Page.View as MainView
import Reader exposing (..)
import Route
import Task exposing (Task)
import Url exposing (Url)



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
    , notifications : UserNotification.Model
    , navKey : Navigation.Key
    , organizationList : List Organization
    }


init : Flags -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init flags location navKey =
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
            , notifications = UserNotification.initModel
            , navKey = navKey
            , organizationList = []
            }

        cmd =
            Task.attempt OrganizationListLoaded (Reader.run requestAllOrganizations ( flags.node_env, flags.organization_key, flags.app_url ))
    in
    ( pageModel, combineCmds cmd readerCmd )



-- MSG


type Msg
    = UserNotificationMsg UserNotification.Msg
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
    | OnLocationChange Url
    | LoginMsg Login.Msg
    | ForgotPasswordMsg ForgotPassword.Msg
    | SignOut
    | SignedOut (Result Http.Error String)
    | SignUpMsg SignUp.Msg
    | OrganizationCreateMsg OrganizationCreate.Msg
    | LinkClicked Browser.UrlRequest
    | OrganizationListLoaded (Result GQLClient.Error (Maybe (List Organization)))
    | UpdateOrganizationData Organization



-- UPDATE


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page


setRoute : Url -> Model -> ( Model, Cmd Msg )
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
                    , readerCmdToCmd model.navKey model.nodeEnv model.organizationKey model.appUrl msg pageCmds
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
            ArticleEdit.initEdit articleId
                |> transitionTo ArticleEdit ArticleEditMsg

        Route.ArticleShow organizationKey articleId ->
            ArticleEdit.init articleId
                |> transitionTo ArticleEdit ArticleEditMsg

        Route.CategoryEdit organizationKey categoryId ->
            CategoryEdit.init categoryId
                |> transitionTo CategoryEdit CategoryEditMsg

        Route.SignUp ->
            SignUp.init
                |> transitionTo SignUp SignUpMsg

        Route.OrganizationCreate ->
            OrganizationCreate.init model.userId
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


combineCmds : Cmd msg -> Cmd msg -> Cmd msg
combineCmds cmd1 cmd2 =
    Cmd.batch <| [ cmd1, cmd2 ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        runReaderCmds =
            readerCmdToCmd model.navKey model.nodeEnv model.organizationKey model.appUrl

        renderFlashMessages message ( newModel, newCmds ) =
            update (UserNotificationMsg (UserNotification.InsertNotification message)) newModel
                |> Tuple.mapSecond
                    (combineCmds <| newCmds)

        updateNavigation route =
            Tuple.mapSecond (combineCmds <| Navigation.pushUrl model.navKey (Route.routeToString route))
    in
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Navigation.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Navigation.load href
                    )

        UserNotificationMsg unMsg ->
            UserNotification.update unMsg model.notifications
                |> Tuple.mapFirst (\unModel -> { model | notifications = unModel })
                |> Tuple.mapSecond (runReaderCmds UserNotificationMsg)

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
            case model.currentPage of
                Loaded (ArticleCreate _) ->
                    ( { model | currentPage = Loaded (ArticleCreate newModel) }
                    , runReaderCmds ArticleCreateMsg cmds
                    )

                TransitioningFrom _ ->
                    ( { model | currentPage = Loaded (ArticleCreate newModel) }
                    , runReaderCmds ArticleCreateMsg cmds
                    )

                _ ->
                    ( model, Cmd.none )

        ArticleEditMsg aeMsg ->
            let
                currentPageModel =
                    case getPage model.currentPage of
                        ArticleEdit articleEditModel ->
                            articleEditModel

                        _ ->
                            case model.route of
                                Route.ArticleEdit _ articleId ->
                                    ArticleEdit.initEditModel articleId

                                Route.ArticleShow _ articleId ->
                                    ArticleEdit.initModel articleId

                                _ ->
                                    ArticleEdit.initModel "0"

                ( newModel, cmds ) =
                    ArticleEdit.update aeMsg
                        currentPageModel
            in
            -- TODO: Make this better. There should be no need to check currentpage type here.
            -- This was done to fix a bug that autonavigated user to an empty article edit page
            case model.currentPage of
                Loaded (ArticleEdit _) ->
                    ( { model | currentPage = Loaded (ArticleEdit newModel) }
                    , runReaderCmds ArticleEditMsg cmds
                    )

                TransitioningFrom _ ->
                    ( { model | currentPage = Loaded (ArticleEdit newModel) }
                    , runReaderCmds ArticleEditMsg cmds
                    )

                _ ->
                    ( model, Cmd.none )

        UrlCreateMsg cuMsg ->
            let
                currentPageModel =
                    case getPage model.currentPage of
                        UrlCreate urlCreateModel ->
                            urlCreateModel

                        _ ->
                            UrlCreate.initModel

                ( newPageModel, cmds ) =
                    UrlCreate.update cuMsg
                        currentPageModel

                ( newModel, newCmds ) =
                    ( { model | currentPage = Loaded (UrlCreate newPageModel) }
                    , runReaderCmds UrlCreateMsg cmds
                    )
            in
            case cuMsg of
                UrlCreate.SaveUrlResponse (Ok urlResponse) ->
                    let
                        updatedModel =
                            { currentPageModel
                                | errors = flattenErrors urlResponse.errors
                            }
                    in
                    case urlResponse.url of
                        Just url ->
                            updateNavigation (Route.UrlList model.organizationKey) ( newModel, newCmds )
                                |> renderFlashMessages (UserNotification.SuccessNotification "Url created successfully.")

                        Nothing ->
                            ( { model | currentPage = Loaded (UrlCreate updatedModel) }
                            , runReaderCmds UrlCreateMsg cmds
                            )

                _ ->
                    ( newModel, newCmds )

        UrlEditMsg ueMsg ->
            let
                currentPageModel =
                    case getPage model.currentPage of
                        UrlEdit urlEditModel ->
                            urlEditModel

                        _ ->
                            UrlEdit.initModel "0"

                ( newPageModel, cmds ) =
                    UrlEdit.update ueMsg currentPageModel

                ( newModel, newCmds ) =
                    ( { model | currentPage = Loaded (UrlEdit newPageModel) }
                    , runReaderCmds UrlEditMsg cmds
                    )
            in
            case ueMsg of
                UrlEdit.UpdateUrlResponse (Ok urlResponse) ->
                    let
                        updatedModel =
                            { currentPageModel
                                | errors = flattenErrors urlResponse.errors
                            }
                    in
                    case urlResponse.url of
                        Just url ->
                            updateNavigation (Route.UrlList model.organizationKey) ( newModel, newCmds )
                                |> renderFlashMessages (UserNotification.SuccessNotification "Url updated successfully.")

                        Nothing ->
                            ( { model | currentPage = Loaded (UrlEdit updatedModel) }
                            , runReaderCmds UrlEditMsg cmds
                            )

                _ ->
                    ( newModel, newCmds )

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

                ( newPageModel, cmds ) =
                    CategoryCreate.update ccMsg
                        currentPageModel

                ( newModel, newCmds ) =
                    ( { model
                        | currentPage = Loaded (CategoryCreate newPageModel)
                      }
                    , runReaderCmds CategoryCreateMsg cmds
                    )
            in
            case ccMsg of
                CategoryCreate.SaveCategoryResponse (Ok categoryResponse) ->
                    let
                        updatedModel =
                            { currentPageModel
                                | errors = flattenErrors categoryResponse.errors
                            }
                    in
                    case categoryResponse.category of
                        Just category ->
                            updateNavigation (Route.CategoryList model.organizationKey) ( newModel, newCmds )
                                |> renderFlashMessages (UserNotification.SuccessNotification "Category created successfully.")

                        Nothing ->
                            ( { model | currentPage = Loaded (CategoryCreate updatedModel) }
                            , runReaderCmds CategoryCreateMsg cmds
                            )

                _ ->
                    ( newModel, newCmds )

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

                ( newPageModel, cmds ) =
                    FeedbackShow.update fsMsg
                        currentPageModel

                ( newModel, newCmds ) =
                    ( { model | currentPage = Loaded (FeedbackShow newPageModel) }
                    , runReaderCmds FeedbackShowMsg cmds
                    )
            in
            case fsMsg of
                FeedbackShow.UpdateFeedbackResponse (Ok feedback) ->
                    updateNavigation (Route.FeedbackList model.organizationKey) ( newModel, newCmds )
                        |> renderFlashMessages
                            (UserNotification.SuccessNotification
                                "Feedback updated successfully."
                            )

                _ ->
                    ( newModel, newCmds )

        CategoryEditMsg ctMsg ->
            let
                currentPageModel =
                    case getPage model.currentPage of
                        CategoryEdit categoryEditModel ->
                            categoryEditModel

                        _ ->
                            CategoryEdit.initModel "0"

                ( newPageModel, cmds ) =
                    CategoryEdit.update ctMsg
                        currentPageModel

                ( newModel, newCmds ) =
                    ( { model | currentPage = Loaded (CategoryEdit newPageModel) }
                    , runReaderCmds CategoryEditMsg cmds
                    )
            in
            case ctMsg of
                CategoryEdit.UpdateCategoryResponse (Ok categoryResponse) ->
                    let
                        updatedModel =
                            { currentPageModel
                                | errors = flattenErrors categoryResponse.errors
                            }
                    in
                    case categoryResponse.category of
                        Just category ->
                            updateNavigation (Route.CategoryList model.organizationKey) ( newModel, newCmds )
                                |> renderFlashMessages (UserNotification.SuccessNotification "Category updated successfully.")

                        Nothing ->
                            ( { model | currentPage = Loaded (CategoryEdit updatedModel) }
                            , runReaderCmds CategoryEditMsg cmds
                            )

                _ ->
                    ( newModel, newCmds )

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

                ( newPageModel, cmds ) =
                    TeamMemberCreate.update tcmsg
                        currentPageModel

                ( newModel, newCmds ) =
                    ( { model | currentPage = Loaded (TeamMemberCreate newPageModel) }
                    , runReaderCmds TeamCreateMsg cmds
                    )
            in
            case tcmsg of
                TeamMemberCreate.SaveTeamResponse (Ok saveTeamResponse) ->
                    let
                        updatedModel =
                            { currentPageModel
                                | errors = flattenErrors saveTeamResponse.errors
                            }
                    in
                    case saveTeamResponse.user of
                        Just user ->
                            updateNavigation (Route.TeamList model.organizationKey) ( newModel, newCmds )
                                |> renderFlashMessages
                                    (UserNotification.SuccessNotification
                                        "Team member added successfully."
                                    )

                        Nothing ->
                            ( { model | currentPage = Loaded (TeamMemberCreate updatedModel) }
                            , runReaderCmds TeamCreateMsg cmds
                            )

                _ ->
                    ( newModel, newCmds )

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
                OrganizationCreate.SaveOrgResponse (Ok organizationResponse) ->
                    let
                        updatedModel =
                            { currentPageModel
                                | errors = flattenErrors organizationResponse.errors
                            }
                    in
                    case organizationResponse.organization of
                        Just org ->
                            ( { model
                                | organizationKey = org.api_key
                                , organizationName = org.name
                              }
                            , Navigation.pushUrl model.navKey
                                (Route.routeToString <|
                                    Route.ArticleList org.api_key
                                )
                            )

                        Nothing ->
                            ( { model | currentPage = Loaded (OrganizationCreate updatedModel) }
                            , runReaderCmds OrganizationCreateMsg cmds
                            )

                _ ->
                    ( { model | currentPage = Loaded (OrganizationCreate newModel) }
                    , runReaderCmds OrganizationCreateMsg cmds
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
            case suMsg of
                SignUp.SignUpResponse (Ok userWithErrors) ->
                    let
                        ( newMainModel, newCmds ) =
                            ( { model | currentPage = Loaded (SignUp newModel) }
                            , runReaderCmds SignUpMsg cmds
                            )

                        userId =
                            case userWithErrors.user of
                                Just user ->
                                    user.id

                                Nothing ->
                                    ""

                        newUpdatedModel =
                            case getPage newMainModel.currentPage of
                                OrganizationCreate orgModel ->
                                    { newMainModel
                                        | userId =
                                            Maybe.withDefault "" <|
                                                Maybe.map .id userWithErrors.user
                                    }

                                _ ->
                                    newMainModel
                    in
                    ( { newUpdatedModel | userId = userId }, newCmds )

                _ ->
                    ( { model | currentPage = Loaded (SignUp newModel) }
                    , runReaderCmds SignUpMsg cmds
                    )

        LoginMsg loginMsg ->
            let
                currentPageModel =
                    case getPage model.currentPage of
                        Login loginModel ->
                            loginModel

                        _ ->
                            Login.initModel

                ( newModel, cmds ) =
                    Login.update loginMsg currentPageModel
            in
            case loginMsg of
                Login.LoginResponse (Ok user) ->
                    let
                        ( updatedModel, updatedCmd ) =
                            case user.organization of
                                Nothing ->
                                    ( model
                                    , Navigation.pushUrl model.navKey
                                        (Route.routeToString Route.OrganizationCreate)
                                    )

                                Just org ->
                                    ( { model
                                        | organizationKey = org.api_key
                                        , organizationName = org.name
                                      }
                                    , Navigation.pushUrl model.navKey
                                        (Route.routeToString <|
                                            Route.ArticleList org.api_key
                                        )
                                    )
                    in
                    ( { updatedModel
                        | userId = user.id
                      }
                    , updatedCmd
                    )

                _ ->
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
            ( model, Http.send SignedOut <| logoutRequest model.nodeEnv model.appUrl )

        SignedOut _ ->
            ( model, Navigation.load (Admin.Request.Helper.baseUrl model.nodeEnv model.appUrl) )

        OrganizationListLoaded (Ok organizationListResponse) ->
            case organizationListResponse of
                Just organizations ->
                    ( { model | organizationList = organizations }, Cmd.none )

                Nothing ->
                    ( model, Cmd.none )

        OrganizationListLoaded (Err _) ->
            ( model, Cmd.none )

        -- TODO: add command to update reader apiKey
        UpdateOrganizationData organization ->
            ( { model
                | organizationKey = organization.api_key
                , organizationName = organization.name
              }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case getPage model.currentPage of
        ArticleEdit articleEditModel ->
            Sub.map ArticleEditMsg <| ArticleEdit.subscriptions articleEditModel

        _ ->
            Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    let
        viewContent =
            case getPage model.currentPage of
                ArticleList articleListModel ->
                    Html.map ArticleListMsg
                        (ArticleList.view model.organizationKey articleListModel)

                ArticleCreate articleCreateModel ->
                    Html.map ArticleCreateMsg
                        (ArticleCreate.view model.organizationKey articleCreateModel)

                ArticleEdit articleEditModel ->
                    Html.map ArticleEditMsg
                        (ArticleEdit.view articleEditModel)

                UrlCreate urlCreateModel ->
                    Html.map UrlCreateMsg
                        (UrlCreate.view urlCreateModel)

                UrlList urlListModel ->
                    Html.map UrlListMsg
                        (UrlList.view model.organizationKey urlListModel)

                CategoryList categoryListModel ->
                    Html.map CategoryListMsg
                        (CategoryList.view model.organizationKey categoryListModel)

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
                        (TicketList.view model.organizationKey ticketListModel)

                UrlEdit urlEditModel ->
                    Html.map UrlEditMsg
                        (UrlEdit.view urlEditModel)

                FeedbackList feedbackListModel ->
                    Html.map FeedbackListMsg
                        (FeedbackList.view model.organizationKey feedbackListModel)

                FeedbackShow feedbackShowModel ->
                    Html.map FeedbackShowMsg
                        (FeedbackShow.view feedbackShowModel)

                TeamList teamListModel ->
                    Html.map TeamListMsg
                        (TeamList.view model.organizationKey teamListModel)

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

                SignUp signupModel ->
                    Html.map SignUpMsg
                        (SignUp.view signupModel)

                Login loginModel ->
                    Html.map LoginMsg (Login.view loginModel)

                ForgotPassword forgotPasswordModel ->
                    Html.map ForgotPasswordMsg
                        (ForgotPassword.view forgotPasswordModel)

        headerContent =
            MainView.adminHeader model.organizationKey model.organizationName model.organizationList model.route SignOut UpdateOrganizationData

        logoutHeaderOption =
            MainView.logoutOption SignOut

        viewWithTopMenu =
            case model.currentPage of
                TransitioningFrom _ ->
                    MainView.adminLayout headerContent
                        UserNotificationMsg
                        True
                        "Loading.."
                        model.notifications
                        [ viewContent ]

                Loaded _ ->
                    MainView.adminLayout headerContent
                        UserNotificationMsg
                        False
                        ""
                        model.notifications
                        [ viewContent ]

        viewBody =
            case getPage model.currentPage of
                Login _ ->
                    viewContent

                SignUp _ ->
                    viewContent

                ForgotPassword _ ->
                    viewContent

                NotFound ->
                    viewContent

                OrganizationCreate _ ->
                    MainView.adminLayout (MainView.logoutOption SignOut)
                        UserNotificationMsg
                        False
                        ""
                        model.notifications
                        [ viewContent ]

                _ ->
                    viewWithTopMenu
    in
    { title = "AceHelp", body = [ div [ id "admin-hook" ] [ viewBody ] ] }



-- MAIN


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , onUrlChange = OnLocationChange
        , onUrlRequest = LinkClicked
        , subscriptions = subscriptions
        }
