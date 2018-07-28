module Route exposing (Route(..), fromLocation, modifyUrl, routeToString)

import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), Parser, oneOf, parsePath, s, string)
import Admin.Data.Article exposing (ArticleId)


-- ROUTING --


type alias OrganizationApiKey =
    String


type Route
    = ArticleList OrganizationApiKey
    | ArticleCreate
    | ArticleEdit ArticleId
    | CategoryList OrganizationApiKey
    | CategoryCreate
    | UrlList OrganizationApiKey
    | UrlCreate
    | TicketList OrganizationApiKey
    | Integration
    | Dashboard
    | NotFound


routeMatcher : Parser (Route -> a) a
routeMatcher =
    oneOf
        [ Url.map Dashboard (s "admin" </> s "")
        , Url.map ArticleList (s "organizations" </> string </> s "articles")
        , Url.map UrlList (s "organizations" </> string </> s "urls")
        , Url.map CategoryList (s "organizations" </> string </> s "categories")
        , Url.map TicketList (s "organizations" </> string </> s "tickets")
        , Url.map Integration (s "integrations")
        , Url.map ArticleCreate (s "articles" </> s "new")
        , Url.map UrlCreate (s "urls" </> s "new")
        , Url.map CategoryCreate (s "categories" </> s "new")
        , Url.map ArticleEdit (s "articles" </> string)
        ]



-- INTERNAL --


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Dashboard ->
                    []

                ArticleList organizationApiKey ->
                    [ "organizations", organizationApiKey, "articles" ]

                UrlList organizationApiKey ->
                    [ "organizations", organizationApiKey, "urls" ]

                CategoryList organizationApiKey ->
                    [ "organizations", organizationApiKey, "categories" ]

                TicketList organizationApiKey ->
                    [ "organizations", organizationApiKey, "tickets" ]

                Integration ->
                    [ "integrations" ]

                ArticleCreate ->
                    [ "articles", "new" ]

                UrlCreate ->
                    [ "urls", "new" ]

                CategoryCreate ->
                    [ "categories", "new" ]

                ArticleEdit articleId ->
                    [ "articles", articleId ]

                NotFound ->
                    []
    in
        "/" ++ String.join "/" pieces


modifyUrl : Route -> Cmd msg
modifyUrl =
    routeToString >> Navigation.modifyUrl


fromLocation : Location -> Route
fromLocation location =
    case parsePath routeMatcher location of
        Just route ->
            route

        _ ->
            NotFound
