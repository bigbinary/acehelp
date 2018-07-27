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
    | CategoryList
    | CategoryCreate
    | UrlList
    | UrlCreate
    | TicketList
    | Integration
    | Dashboard
    | NotFound


routeMatcher : Parser (Route -> a) a
routeMatcher =
    oneOf
        [ Url.map Dashboard (s "admin" </> s "")
        , Url.map ArticleList (s "organizations" </> string </> s "articles")
        , Url.map UrlList (s "urls")
        , Url.map CategoryList (s "categories")
        , Url.map TicketList (s "tickets")
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

                UrlList ->
                    [ "urls" ]

                CategoryList ->
                    [ "categories" ]

                TicketList ->
                    [ "tickets" ]

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
