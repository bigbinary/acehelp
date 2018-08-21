module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (id, class, style)
import Html.Events exposing (onClick)
import Section.Article.SuggestedList as SuggestedList
import Section.Article.Article as Article
import Section.Library.Library as Library
import Section.Library.Category as Category
import Section.Contact.ContactUs as ContactUs
import Views.Container exposing (topBar)
import Views.Loading exposing (sectionLoadingView)
import Views.Tabs as Tabs
import Section.Search.SearchBar as SearchBar
import Data.Article exposing (ArticleId, ArticleResponse, ArticleSummary)
import Data.Organization exposing (..)
import Data.Common exposing (..)
import Request.Organization exposing (..)
import Request.Helpers exposing (ApiKey, NodeEnv, Context(..))
import Utils exposing (getUrlPathData)
import Animation
import Navigation
import FontAwesome.Solid as SolidIcon
import Ports exposing (..)


-- MODEL


type alias Flags =
    { node_env : String
    , api_key : String
    }


type AppState
    = Minimized
    | Maximized


type Section
    = Blank
    | Loading
    | SuggestedArticlesSection SuggestedList.Model
    | ArticleSection Article.Model
    | LibrarySection Library.Model
    | CategorySection Category.Model
    | ContactUsSection ContactUs.Model


type SectionState
    = Loaded Section
    | TransitioningFrom Section


type alias Model =
    { nodeEnv : NodeEnv
    , apiKey : ApiKey
    , sectionState : SectionState
    , containerAnimation : Animation.State
    , currentAppState : AppState
    , context : Context
    , tabModel : Tabs.Model
    , searchQuery : SearchBar.Model
    , history : ModelHistory
    , userInfo : UserInfo
    , renderHelpButton : Bool
    }


type ModelHistory
    = ModelHistory Model
    | NoHistory



-- INIT


initAnimation : List Animation.Property
initAnimation =
    [ Animation.opacity 0
    , Animation.right <| Animation.px -770
    ]


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    ( { nodeEnv = flags.node_env
      , apiKey = flags.api_key
      , sectionState = Loaded Blank
      , containerAnimation = Animation.style initAnimation
      , currentAppState = Minimized
      , context = Context <| getUrlPathData location
      , tabModel = Tabs.modelWithTabs Tabs.allTabs
      , searchQuery = ""
      , history = NoHistory
      , userInfo = { name = "", email = "" }
      , renderHelpButton = True
      }
    , Task.attempt OrganizationLoaded
        (Reader.run (requestOrganizations flags.api_key) ( flags.node_env, flags.api_key ))
    )



-- UPDATE


type Msg
    = Animate Animation.Msg
    | OrganizationLoaded (Result GQLClient.Error Organization)
    | SetAppState AppState
    | SuggestedArticlesMsg SuggestedList.Msg
    | ArticleMsg Article.Msg
    | LibraryMsg Library.Msg
    | CategoryMsg Category.Msg
    | UrlChange Navigation.Location
    | GoBack
    | TabMsg Tabs.Msg
    | ContactUsMsg ContactUs.Msg
    | SearchBarMsg SearchBar.Msg
    | ReceivedUserInfo UserInfo
    | OpenArticleWithId ArticleId


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        transitionToSection =
            transitionTo model

        runReaderCmds =
            sectionCmdToCmd model.nodeEnv model.apiKey
    in
        case msg of
            Animate animationMsg ->
                ( { model
                    | containerAnimation =
                        Animation.update animationMsg
                            model.containerAnimation
                  }
                , Cmd.none
                )

            OrganizationLoaded (Ok organization) ->
                ( { model | renderHelpButton = True }, Cmd.none )

            OrganizationLoaded (Err error) ->
                ( { model | renderHelpButton = False }, Cmd.none )

            SetAppState appState ->
                let
                    ( animation, newSectionState, cmd ) =
                        setAppState appState model
                in
                    ( { model
                        | currentAppState = appState
                        , containerAnimation =
                            animation
                        , sectionState = newSectionState
                      }
                    , cmd
                    )

            TabMsg tabMsg ->
                let
                    ( newModel, newCmd ) =
                        case tabMsg of
                            Tabs.TabSelected newTab ->
                                onTabChange newTab model

                    ( newTabModel, tabCmd ) =
                        Tabs.update tabMsg model.tabModel
                in
                    ( { newModel | tabModel = newTabModel }
                    , Cmd.batch
                        [ newCmd
                        , Cmd.map TabMsg tabCmd
                        ]
                    )

            SuggestedArticlesMsg sectionMsg ->
                let
                    currentModel =
                        case getSection model.sectionState of
                            SuggestedArticlesSection model ->
                                model

                            _ ->
                                SuggestedList.initModel

                    ( newModel, cmds ) =
                        SuggestedList.update sectionMsg currentModel
                in
                    ( { model | sectionState = Loaded (SuggestedArticlesSection newModel) }
                    , runReaderCmds SuggestedArticlesMsg cmds
                    )

            ArticleMsg sectionMsg ->
                let
                    currentModel =
                        case getSection model.sectionState of
                            ArticleSection model ->
                                model

                            _ ->
                                Article.initModel

                    ( newModel, cmds ) =
                        Article.update sectionMsg currentModel
                in
                    ( { model | sectionState = Loaded (ArticleSection newModel) }
                    , runReaderCmds ArticleMsg cmds
                    )

            LibraryMsg sectionMsg ->
                let
                    currentModel =
                        case getSection model.sectionState of
                            LibrarySection model ->
                                model

                            _ ->
                                Library.initModel

                    ( newModel, cmds ) =
                        Library.update sectionMsg currentModel
                in
                    case sectionMsg of
                        Library.LoadCategory categoryId ->
                            transitionToSection CategorySection CategoryMsg (Category.init <| Library.getCategoryWithId categoryId currentModel)

                        _ ->
                            ( { model | sectionState = Loaded (LibrarySection newModel) }
                            , runReaderCmds LibraryMsg cmds
                            )

            CategoryMsg sectionMsg ->
                let
                    currentModel =
                        case getSection model.sectionState of
                            CategorySection model ->
                                model

                            _ ->
                                Category.initModel

                    ( newModel, cmds ) =
                        Category.update sectionMsg currentModel
                in
                    case sectionMsg of
                        Category.LoadArticle articleId ->
                            transitionToSection ArticleSection ArticleMsg (Article.init articleId)

            ContactUsMsg sectionMsg ->
                let
                    currentModel =
                        case getSection model.sectionState of
                            ContactUsSection model ->
                                model

                            _ ->
                                ContactUs.initModel model.userInfo.name model.userInfo.email

                    ( newModel, cmds ) =
                        ContactUs.update sectionMsg currentModel
                in
                    ( { model | sectionState = Loaded (ContactUsSection newModel) }
                    , runReaderCmds ContactUsMsg cmds
                    )

            GoBack ->
                ( getPreviousValidState model, Cmd.none )

            UrlChange location ->
                ( { model | context = Context (getUrlPathData location) }, Cmd.none )

            OpenArticleWithId articleId ->
                let
                    ( animation, newSectionState, _ ) =
                        setAppState Maximized model

                    ( _, cmd ) =
                        Article.init articleId
                in
                    ( { model
                        | currentAppState = Maximized
                        , containerAnimation = animation
                        , sectionState = newSectionState
                      }
                    , sectionCmdToCmd model.nodeEnv model.apiKey ArticleMsg cmd
                    )

            SearchBarMsg searchBarMsg ->
                ( model, Cmd.none )

            ReceivedUserInfo userInfo ->
                ( { model | userInfo = userInfo }, Cmd.none )


getSectionView : Section -> Html Msg
getSectionView section =
    case section of
        Blank ->
            sectionLoadingView

        Loading ->
            sectionLoadingView

        SuggestedArticlesSection sectionModel ->
            Html.map SuggestedArticlesMsg <| SuggestedList.view sectionModel

        ArticleSection sectionModel ->
            Html.map ArticleMsg <| Article.view sectionModel

        LibrarySection sectionModel ->
            Html.map LibraryMsg <| Library.view sectionModel

        CategorySection sectionModel ->
            Html.map CategoryMsg <| Category.view sectionModel

        ContactUsSection sectionModel ->
            Html.map ContactUsMsg <| ContactUs.view sectionModel


getSection : SectionState -> Section
getSection sectionState =
    case sectionState of
        Loaded section ->
            section

        TransitioningFrom section ->
            Loading


getModelFromHistory : Model -> Maybe Model
getModelFromHistory modelHistory =
    case modelHistory.history of
        ModelHistory model ->
            Just model

        NoHistory ->
            Nothing


getPreviousValidState : Model -> Model
getPreviousValidState currentModel =
    let
        getValidModelFromSection model =
            case model of
                Just newModel ->
                    case (getSection newModel.sectionState) of
                        Blank ->
                            -- Blank indicates start of app
                            currentModel

                        Loading ->
                            getValidModelFromSection (getModelFromHistory newModel)

                        _ ->
                            newModel

                Nothing ->
                    currentModel

        previousModel =
            getValidModelFromSection <| getModelFromHistory currentModel
    in
        previousModel


setAppState : AppState -> Model -> ( Animation.State, SectionState, Cmd Msg )
setAppState appState model =
    case appState of
        Maximized ->
            let
                ( _, cmd ) =
                    SuggestedList.init model.context
            in
                ( Animation.interrupt
                    [ Animation.to
                        [ Animation.opacity 1
                        , Animation.right <| Animation.px 0
                        ]
                    ]
                    model.containerAnimation
                , TransitioningFrom (getSection model.sectionState)
                , sectionCmdToCmd model.nodeEnv model.apiKey SuggestedArticlesMsg cmd
                )

        Minimized ->
            ( Animation.interrupt
                [ Animation.to initAnimation ]
                model.containerAnimation
            , Loaded Blank
            , Cmd.none
            )

transitionTo : Model -> (b -> Section) -> (msg -> msg1) -> ( b, List (SectionCmd msg) ) -> ( Model, Cmd msg1 )
transitionTo model sec msg ( sectionModel, sectionCmds ) =
    case sectionCmds of
        [] ->
            ( { model | sectionState = Loaded (sec sectionModel) }
            , Cmd.none
            )

        _ ->
            ( { model | sectionState = TransitioningFrom (getSection model.sectionState) }
            , sectionCmdToCmd model.nodeEnv model.apiKey msg sectionCmds
            )


onTabChange : Tabs.Tabs -> Model -> ( Model, Cmd Msg )
onTabChange tab model =
    let
        transitionToTab =
            transitionTo model
    in
        case tab of
            Tabs.SuggestedArticles ->
                SuggestedList.init model.context
                    |> transitionToTab SuggestedArticlesSection SuggestedArticlesMsg

            Tabs.Library ->
                Library.init
                    |> transitionToTab LibrarySection LibraryMsg

            Tabs.ContactUs ->
                ContactUs.init model.userInfo.name model.userInfo.email
                    |> transitionToTab ContactUsSection ContactUsMsg



-- VIEW


minimizedView :  Model -> Html Msg
minimizedView =
    case model.renderHelpButton of
        True ->
            div
                [ id "mini-view"
                , style
                    [ ( "background-color", "rgb(60, 170, 249)" )
                    , ( "color", "#fff" )
                    ]
                , onClick (SetAppState Maximized)
                ]
                [ div [ class "question-icon" ]
                    [ SolidIcon.question ]
                ]
        _->
            div [] []


maximizedView : Model -> Html Msg
maximizedView model =
    let
        history =
            getModelFromHistory model

        showBackButton =
            case history of
                Just previousModel ->
                    case (getSection previousModel.sectionState) of
                        Blank ->
                            False

                        Loading ->
                            False

                        _ ->
                            True

                Nothing ->
                    False
    in
        div
            (List.concat
                [ Animation.render model.containerAnimation
                , [ id "max-view"
                  ]
                ]
            )
            [ topBar showBackButton GoBack (SetAppState Minimized)
            , Html.map TabMsg <| Tabs.view model.tabModel
            , Html.map SearchBarMsg <| SearchBar.view model.searchQuery "rgb(60, 170, 249)"
            , getSectionView <| getSection model.sectionState
            ]


view : Model -> Html Msg
view model =
    case model.currentAppState of
        Minimized ->
            minimizedView model

        Maximized ->
            maximizedView model



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Animation.subscription Animate [ model.containerAnimation ]
        , userInfo <| decodeUserInfo >> ReceivedUserInfo
        , openArticle <| OpenArticleWithId
        ]



-- MAIN


main : Program Flags Model Msg
main =
    Navigation.programWithFlags UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
