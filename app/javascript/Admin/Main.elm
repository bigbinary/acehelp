module Main exposing (..)

import Html exposing (Html, div, text, button)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)
import Page.Article.List as ArticleList
import Page.Article.Create as ArticleCreate
import Page.Url.List as UrlList
import Page.Url.Create as UrlCreate
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
    }


type Page
    = ArticleList ArticleList.Model
    | ArticleCreate ArticleCreate.Model
    | CategoryList CategoryList.Model
    | CategoryCreate CategoryCreate.Model
    | UrlList UrlList.Model
    | UrlCreate UrlCreate.Model
    | OrganizationShow OrganizationShow.Model
    | NotFound


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    let
        ( pageModel, pageCmd ) =
            retrivePage location

        initModel =
            { currentPage = pageModel
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
    | OrganizationShowMsg OrganizationShow.Msg


-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Navigate page ->
            ( model, newUrl <| convertPageToHash page )

        ChangePage page cmd ->
            ( { model | currentPage = page }, cmd )

        ArticleListMsg alMsg ->
            let
                ( articleListModel, articleListCmd ) =
                    ArticleList.update alMsg ArticleList.initModel
            in
                ( { model | currentPage = (ArticleList articleListModel) }
                , Cmd.map ArticleListMsg articleListCmd
                )

        ArticleCreateMsg caMsg ->
            let
                ( createArticleModel, createArticleCmd ) =
                    ArticleCreate.update caMsg ArticleCreate.initModel
            in
                ( { model | currentPage = (ArticleCreate createArticleModel) }
                , Cmd.map ArticleCreateMsg createArticleCmd
                )

        UrlCreateMsg cuMsg ->
            let
                ( createUrlModel, createUrlCmds ) =
                    UrlCreate.update cuMsg UrlCreate.initModel
            in
                ( { model | currentPage = (UrlCreate createUrlModel) }
                , Cmd.map UrlCreateMsg createUrlCmds
                )

        UrlListMsg ulMsg ->
            let
                ( urlListModel, urlListCmds ) =
                    UrlList.update ulMsg UrlList.initModel
            in
                ( { model | currentPage = (UrlList urlListModel) }
                , Cmd.map UrlListMsg urlListCmds
                )

        CategoryListMsg clMsg ->
            let
                ( categoryListModel, categoryListCmd ) =
                    CategoryList.update clMsg CategoryList.initModel
            in
                ( { model | currentPage = (CategoryList categoryListModel) }
                , Cmd.map CategoryListMsg categoryListCmd
                )

        CategoryCreateMsg ccMsg ->
            let
                ( categoryCreateModel, categoryCreateCmd ) =
                    CategoryCreate.update ccMsg CategoryCreate.initModel
            in
                ( { model
                    | currentPage = (CategoryCreate categoryCreateModel)
                  }
                , Cmd.map CategoryCreateMsg categoryCreateCmd
                )

        OrganizationShowMsg osMsg ->
            let
                ( organizationShowModel, organizationShowCmd ) =
                    OrganizationShow.update osMsg OrganizationShow.initModel
            in
                ( { model
                    | currentPage = OrganizationShow organizationShowModel
                  }
                , Cmd.map OrganizationShowMsg organizationShowCmd
                )


convertPageToHash : Page -> String
convertPageToHash page =
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

        OrganizationShow organizationShowModel->
            "/admin/organization/1"

        NotFound ->
            "/404"


urlLocationToMsg : Location -> Msg
urlLocationToMsg location =
    let
        ( pageModel, pageCmd ) =
            location
                |> retrivePage
    in
        ChangePage pageModel pageCmd


retrivePage : Location -> ( Page, Cmd Msg )
retrivePage location =
    case ( extractStaticPath location ) of
        "/admin/articles" ->
            let
                ( pageModel, pageCmd ) =
                    ArticleList.init
            in
                ( ArticleList pageModel, Cmd.map ArticleListMsg pageCmd )

        "/admin/articles/new" ->
            let
                ( pageModel, pageCmd ) =
                    (ArticleCreate.init)
            in
                ( ArticleCreate pageModel, Cmd.map ArticleCreateMsg pageCmd )

        "/admin/urls" ->
            let
                ( pageModel, pageCmd ) =
                    UrlList.init
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

        "/admin/organization" ->
            let
                ( pageModel, pageCmd ) =
                    OrganizationShow.init (retriveOrganizationFromUrl location)
            in
                ( OrganizationShow pageModel, Cmd.map OrganizationShowMsg pageCmd )

        _ ->
            ( NotFound, Cmd.none )


extractStaticPath : Location -> String
extractStaticPath location =
        let
            staticPath = (Debug.log "" (parsePath ( s "admin" </> s "organization" </> string ) location))
            path =
                case staticPath of
                    Nothing ->
                        location.pathname

                    Just staticPath ->
                        staticPath
        in
            case path of
            "1" ->
                "/admin/organization"

            "2" ->
                "/admin/organization"

            _ ->
               location.pathname



retriveOrganizationFromUrl : Location -> OrganizationId
retriveOrganizationFromUrl location =
   let
      org = parsePath ( s "admin" </> s "organization" </> int ) location
   in
       getOrganizationId ( org )


getOrganizationId : Maybe Int -> OrganizationId
getOrganizationId orgId =
    case orgId of
        Just orgId ->
          orgId

        Nothing ->
          -1



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

                OrganizationShow organizationShowModel->
                    Html.map OrganizationShowMsg
                        (OrganizationShow.view organizationShowModel)

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
