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


-- MODEL


type alias Flags =
    { node_env : String
    , organization_key : String
    }


type alias Model =
    { currentPage : Page
    , nodeEnv : String
    , organizationKey : String
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


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        ( pageModel, pageCmd ) =
            retrivePage flags.node_env location flags.organization_key

        initModel =
            { currentPage = pageModel
            , nodeEnv = flags.node_env
            , organizationKey = flags.organization_key
            }
    in
        ( initModel, pageCmd )



-- MSG


type Msg
    = Navigate Page
    | ChangePage Page (Cmd Msg)
    | ArticleListMsg ArticleList.Msg
    | ArticleCreateMsg ArticleCreate.Msg
    | UrlCreateMsg UrlCreate.Msg
    | UrlListMsg UrlList.Msg
    | CategoryListMsg CategoryList.Msg
    | CategoryCreateMsg CategoryCreate.Msg
    | IntegrationMsg Integration.Msg
    | UrlLocationChange Navigation.Location
    | SignOut
    | SignedOut (Result Http.Error String)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Navigate page ->
            ( model, newUrl <| convertPageToHash page model.organizationKey )

        ChangePage page cmd ->
            ( { model | currentPage = page }, cmd )

        ArticleListMsg alMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        ArticleList articleListModel ->
                            articleListModel

                        _ ->
                            ArticleList.initModel

                ( articleListModel, articleListCmd ) =
                    ArticleList.update alMsg currentPageModel model.organizationKey model.nodeEnv
            in
                ( { model | currentPage = (ArticleList articleListModel) }
                , Cmd.map ArticleListMsg articleListCmd
                )

        ArticleCreateMsg caMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        ArticleCreate articleCreateModel ->
                            articleCreateModel

                        _ ->
                            ArticleCreate.initModel

                ( articleCreateModel, createArticleCmd ) =
                    ArticleCreate.update caMsg currentPageModel model.nodeEnv model.organizationKey
            in
                ( { model | currentPage = (ArticleCreate articleCreateModel) }
                , Cmd.map ArticleCreateMsg createArticleCmd
                )

        UrlCreateMsg cuMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        UrlCreate urlCreateModel ->
                            urlCreateModel

                        _ ->
                            UrlCreate.initModel

                ( createUrlModel, createUrlCmds ) =
                    UrlCreate.update cuMsg currentPageModel model.nodeEnv model.organizationKey
            in
                ( { model | currentPage = (UrlCreate createUrlModel) }
                , Cmd.map UrlCreateMsg createUrlCmds
                )

        UrlListMsg ulMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        UrlList urlListModel ->
                            urlListModel

                        _ ->
                            UrlList.initModel

                ( urlListModel, urlListCmds ) =
                    UrlList.update ulMsg currentPageModel
            in
                ( { model | currentPage = (UrlList urlListModel) }
                , Cmd.map UrlListMsg urlListCmds
                )

        CategoryListMsg clMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        CategoryList categoryListModel ->
                            categoryListModel

                        _ ->
                            CategoryList.initModel

                ( categoryListModel, categoryListCmd ) =
                    CategoryList.update clMsg currentPageModel
            in
                ( { model | currentPage = (CategoryList categoryListModel) }
                , Cmd.map CategoryListMsg categoryListCmd
                )

        CategoryCreateMsg ccMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        CategoryCreate categoryCreateModel ->
                            categoryCreateModel

                        _ ->
                            CategoryCreate.initModel

                ( categoryCreateModel, categoryCreateCmd ) =
                    CategoryCreate.update ccMsg currentPageModel model.nodeEnv model.organizationKey
            in
                ( { model
                    | currentPage = (CategoryCreate categoryCreateModel)
                  }
                , Cmd.map CategoryCreateMsg categoryCreateCmd
                )

        IntegrationMsg integrationMsg ->
            let
                currentPageModel =
                    case model.currentPage of
                        Integration integrationPageModel ->
                            integrationPageModel

                        _ ->
                            Integration.initModel model.organizationKey

                ( integrationModel, integrationCmd ) =
                    Integration.update integrationMsg currentPageModel
            in
                ( { model
                    | currentPage = (Integration integrationModel)
                  }
                , Cmd.map IntegrationMsg integrationCmd
                )

        UrlLocationChange location ->
            let
                msg =
                    urlLocationToMsg model location
            in
                update msg model

        SignOut ->
            ( model, Http.send SignedOut (logoutRequest model.nodeEnv) )

        SignedOut _ ->
            ( model, load (Request.RequestHelper.baseUrl model.nodeEnv) )


convertPageToHash : Page -> ApiKey -> String
convertPageToHash page organizationKey =
    case page of
        ArticleList articleListModel ->
            "/admin/articles"

        ArticleCreate articleCreateModel ->
            "/admin/articles/new"

        UrlList urlListModel ->
            "/admin/urls"

        UrlCreate urlCreateModel ->
            "/admin/urls/new"

        CategoryList categoryListModel ->
            "/admin/categories"

        CategoryCreate categoryCreateModel ->
            "/admin/categories/new"

        Integration integrationModel ->
            "/admin/integrations?api_key=" ++ organizationKey

        Dashboard ->
            "/admin/dashboard"

        NotFound ->
            "/404"


urlLocationToMsg : Model -> Location -> Msg
urlLocationToMsg model location =
    let
        ( pageModel, pageCmd ) =
            retrivePage model.nodeEnv location model.organizationKey
    in
        ChangePage pageModel pageCmd


retrivePage : NodeEnv -> Location -> ApiKey -> ( Page, Cmd Msg )
retrivePage env location organizationKey =
    let
        integrationsUrl =
            "/admin/integrations?api_key=" ++ organizationKey
    in
        case (extractStaticPath location) of
            "/admin/articles" ->
                let
                    ( pageModel, pageCmd ) =
                        ArticleList.init env organizationKey
                in
                    ( ArticleList pageModel, Cmd.map ArticleListMsg pageCmd )

            "/admin/articles/new" ->
                let
                    ( pageModel, pageCmd ) =
                        (ArticleCreate.init env organizationKey)
                in
                    ( ArticleCreate pageModel, Cmd.map ArticleCreateMsg pageCmd )

            "/admin/urls" ->
                let
                    ( pageModel, pageCmd ) =
                        UrlList.init env organizationKey
                in
                    ( UrlList pageModel, Cmd.map UrlListMsg pageCmd )

            "/admin/urls/new" ->
                let
                    ( pageModel, pageCmd ) =
                        UrlCreate.init
                in
                    ( UrlCreate pageModel, Cmd.map UrlCreateMsg pageCmd )

            "/admin/categories" ->
                let
                    ( pageModel, pageCmd ) =
                        CategoryList.init
                in
                    ( CategoryList pageModel, Cmd.map CategoryListMsg pageCmd )

            "/admin/categories/new" ->
                let
                    ( pageModel, pageCmd ) =
                        CategoryCreate.init
                in
                    ( CategoryCreate pageModel, Cmd.map CategoryCreateMsg pageCmd )

            "/admin/dashboard" ->
                ( Dashboard, Cmd.none )

            integrationsUrl ->
                let
                    ( pageModel, pageCmd ) =
                        Integration.init organizationKey
                in
                    ( Integration pageModel, Cmd.map IntegrationMsg pageCmd )


extractStaticPath : Location -> String
extractStaticPath location =
    let
        staticPath =
            parsePath (s "admin" </> s "organization" </> string) location
    in
        case staticPath of
            Nothing ->
                location.pathname

            Just staticPath ->
                "/admin/organization"


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
            case model.currentPage of
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
            [ Html.a [ onClick (Navigate <| ArticleList ArticleList.initModel) ] [ text "Articles" ]
            , Html.a [ onClick (Navigate <| UrlList UrlList.initModel) ] [ text "URL" ]
            , Html.a [ onClick (Navigate <| CategoryList CategoryList.initModel) ] [ text "Category" ]
            , Html.a [ onClick (Navigate <| Integration (Integration.initModel model.organizationKey)) ] [ text "Integrations" ]
            , Html.a [ onClick SignOut ] [ text "Logout" ]
            ]
        ]



-- MAIN


main : Program Flags Model Msg
main =
    Navigation.programWithFlags UrlLocationChange
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
