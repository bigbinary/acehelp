module Route exposing (Route(..), fromLocation, modifyUrl, routeToString)

import Admin.Data.Article exposing (ArticleId)
import Admin.Data.Category exposing (CategoryId)
import Admin.Data.Feedback exposing (FeedbackId)
import Admin.Data.Url exposing (UrlId)
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), Parser, oneOf, parsePath, s, string)


-- ROUTING --


type alias OrganizationApiKey =
    String


type Route
    = ArticleList OrganizationApiKey
    | ArticleCreate OrganizationApiKey
    | ArticleEdit OrganizationApiKey ArticleId
    | CategoryList OrganizationApiKey
    | CategoryCreate OrganizationApiKey
    | CategoryEdit CategoryId
    | UrlList OrganizationApiKey
    | UrlCreate OrganizationApiKey
    | UrlEdit OrganizationApiKey UrlId
    | TicketList OrganizationApiKey
    | TicketEdit OrganizationApiKey String
    | FeedbackList OrganizationApiKey
    | FeedbackShow OrganizationApiKey FeedbackId
    | Settings OrganizationApiKey
    | Dashboard
    | NotFound
    | OrganizationCreate


routeMatcher : Parser (Route -> a) a
routeMatcher =
    oneOf
        [ Url.map Dashboard (s "admin" </> s "")
        , Url.map ArticleList (s "organizations" </> string </> s "articles")
        , Url.map UrlList (s "organizations" </> string </> s "urls")
        , Url.map CategoryList (s "organizations" </> string </> s "categories")
        , Url.map TicketList (s "organizations" </> string </> s "tickets")
        , Url.map FeedbackList (s "organizations" </> string </> s "feedbacks")
        , Url.map FeedbackShow (s "organizations" </> string </> s "feedbacks" </> string)
        , Url.map Settings (s "organizations" </> string </> s "settings")
        , Url.map ArticleCreate (s "organizations" </> string </> s "articles" </> s "new")
        , Url.map UrlCreate (s "organizations" </> string </> s "urls" </> s "new")
        , Url.map CategoryCreate (s "organizations" </> string </> s "categories" </> s "new")
        , Url.map ArticleEdit (s "organizations" </> string </> s "articles" </> string)
        , Url.map UrlEdit (s "organizations" </> string </> s "urls" </> string </> s "edit")
        , Url.map TicketEdit (s "organizations" </> string </> s "tickets" </> string)
        , Url.map OrganizationCreate (s "organizations" </> s "new")
        , Url.map CategoryEdit (s "categories" </> string)
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

                FeedbackList organizationApiKey ->
                    [ "organizations", organizationApiKey, "feedbacks" ]

                FeedbackShow organizationApiKey feedbackId ->
                    [ "organizations", organizationApiKey, "feedbacks", feedbackId ]

                Settings organizationApiKey ->
                    [ "organizations", organizationApiKey, "settings" ]

                ArticleCreate organizationApiKey ->
                    [ "organizations", organizationApiKey, "articles", "new" ]

                UrlCreate organizationApiKey ->
                    [ "organizations", organizationApiKey, "urls", "new" ]

                CategoryCreate organizationApiKey ->
                    [ "organizations", organizationApiKey, "categories", "new" ]

                UrlEdit organizationApiKey urlId ->
                    [ "organizations", organizationApiKey, "urls", urlId, "edit" ]

                ArticleEdit organizationApiKey articleId ->
                    [ "organizations", organizationApiKey, "articles", articleId ]

                TicketEdit organizationApiKey ticketId ->
                    [ "organizations", organizationApiKey, "tickets", ticketId ]

                OrganizationCreate ->
                    [ "organizations", "new" ]

                CategoryEdit categoryId ->
                    [ "categories", categoryId ]

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
