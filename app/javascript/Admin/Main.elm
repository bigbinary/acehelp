module Main exposing (..)

import Html exposing (Html, div, text, button)
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
import Data.Organization exposing (OrganizationId)
import UrlParser as Url exposing (..)
import Request.RequestHelper exposing (NodeEnv, ApiKey, logoutRequest)
import Route


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
    | UrlCreateMsg UrlCreate.Msg
    | UrlListMsg UrlList.Msg
    | CategoryListMsg CategoryList.Msg
    | CategoryCreateMsg CategoryCreate.Msg
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
                (\pageModel -> ({ model | currentPage = TransitioningTo (page pageModel) }))
                >> Tuple.mapSecond
                    (Cmd.map msg)
    in
        case newRoute of
            Route.ArticleList ->
                (ArticleList.init model.nodeEnv model.organizationKey)
                    |> transitionTo ArticleList ArticleListMsg

            Route.ArticleCreate ->
                (ArticleCreate.init model.nodeEnv model.organizationKey)
                    |> transitionTo ArticleCreate ArticleCreateMsg

            Route.CategoryList ->
                (CategoryList.init)
                    |> transitionTo CategoryList CategoryListMsg

            Route.CategoryCreate ->
                (CategoryCreate.init)
                    |> transitionTo CategoryCreate CategoryCreateMsg

            Route.UrlList ->
                (UrlList.init model.nodeEnv model.organizationKey)
                    |> transitionTo UrlList UrlListMsg

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
            parsePath (s "admin" </> s "organization" </> string) location
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
    let
        page =
            case (getPage model.currentPage) of
                ArticleList articleListModel ->
                    Html.map ArticleListMsg
                        (ArticleList.view articleListModel)

                ArticleCreate articleCreateModel ->
                    Html.map ArticleCreateMsg
                        (ArticleCreate.view articleCreateModel)

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

                Integration integrationModel ->
                    Html.map IntegrationMsg
                        (Integration.view integrationModel)

                Dashboard ->
                    div [] [ text "Dashboard" ]

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
            [ Html.a [ onClick <| NavigateTo Route.ArticleList ] [ text "Articles" ]
            , Html.a [ onClick <| NavigateTo Route.UrlList ] [ text "URL" ]
            , Html.a [ onClick <| NavigateTo Route.CategoryList ] [ text "Category" ]
            , Html.a [ onClick <| NavigateTo Route.Integration ] [ text "Integrations" ]
            , Html.a [ onClick SignOut ] [ text "Logout" ]
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
