module Route exposing (Route(..), fromLocation, routeToString)

import Admin.Data.Article exposing (ArticleId)
import Admin.Data.Category exposing (CategoryId)
import Admin.Data.Feedback exposing (FeedbackId)
import Admin.Data.Url exposing (UrlId)
import Admin.Request.Helper exposing (..)
import Browser.Navigation as Navigation exposing (Key)
import Url exposing (Url)
import Url.Parser as UrlParser exposing ((</>), Parser, oneOf, parse, s, string)


type Route
    = ArticleList ApiKey
    | ArticleCreate ApiKey
    | ArticleEdit ApiKey ArticleId
    | ArticleShow ApiKey ArticleId
    | CategoryList ApiKey
    | CategoryCreate ApiKey
    | CategoryEdit ApiKey CategoryId
    | UrlList ApiKey
    | UrlCreate ApiKey
    | UrlEdit ApiKey UrlId
    | TicketList ApiKey
    | TicketEdit ApiKey String
    | FeedbackList ApiKey
    | FeedbackShow ApiKey FeedbackId
    | TeamList ApiKey
    | TeamMemberCreate ApiKey
    | Settings ApiKey
    | SignUp
    | Dashboard
    | NotFound
    | OrganizationCreate
    | Login
    | ForgotPassword


routeMatcher : Parser (Route -> a) a
routeMatcher =
    oneOf
        [ UrlParser.map Dashboard (s "admin" </> s "")
        , UrlParser.map ArticleList (s "organizations" </> string </> s "articles")
        , UrlParser.map UrlList (s "organizations" </> string </> s "urls")
        , UrlParser.map CategoryList (s "organizations" </> string </> s "categories")
        , UrlParser.map TicketList (s "organizations" </> string </> s "tickets")
        , UrlParser.map FeedbackList (s "organizations" </> string </> s "feedbacks")
        , UrlParser.map FeedbackShow (s "organizations" </> string </> s "feedbacks" </> string)
        , UrlParser.map TeamList (s "organizations" </> string </> s "team")
        , UrlParser.map Settings (s "organizations" </> string </> s "settings")
        , UrlParser.map ArticleCreate (s "organizations" </> string </> s "articles" </> s "new")
        , UrlParser.map UrlCreate (s "organizations" </> string </> s "urls" </> s "new")
        , UrlParser.map CategoryCreate (s "organizations" </> string </> s "categories" </> s "new")
        , UrlParser.map TeamMemberCreate (s "organizations" </> string </> s "team" </> s "new")
        , UrlParser.map ArticleEdit (s "organizations" </> string </> s "articles" </> s "edit" </> string)
        , UrlParser.map ArticleShow (s "organizations" </> string </> s "articles" </> s "show" </> string)
        , UrlParser.map UrlEdit (s "organizations" </> string </> s "urls" </> string </> s "edit")
        , UrlParser.map TicketEdit (s "organizations" </> string </> s "tickets" </> string)
        , UrlParser.map OrganizationCreate (s "organizations" </> s "new")
        , UrlParser.map CategoryEdit (s "organizations" </> string </> s "categories" </> string)
        , UrlParser.map SignUp (s "users" </> s "sign_up")
        , UrlParser.map Login (s "users" </> s "sign_in")
        , UrlParser.map ForgotPassword (s "users" </> s "forgot_password")
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

                TeamList organizationApiKey ->
                    [ "organizations", organizationApiKey, "team" ]

                Settings organizationApiKey ->
                    [ "organizations", organizationApiKey, "settings" ]

                ArticleCreate organizationApiKey ->
                    [ "organizations", organizationApiKey, "articles", "new" ]

                UrlCreate organizationApiKey ->
                    [ "organizations", organizationApiKey, "urls", "new" ]

                CategoryCreate organizationApiKey ->
                    [ "organizations", organizationApiKey, "categories", "new" ]

                TeamMemberCreate organizationApiKey ->
                    [ "organizations", organizationApiKey, "team", "new" ]

                UrlEdit organizationApiKey urlId ->
                    [ "organizations", organizationApiKey, "urls", urlId, "edit" ]

                ArticleEdit organizationApiKey articleId ->
                    [ "organizations", organizationApiKey, "articles", "edit", articleId ]

                ArticleShow organizationApiKey articleId ->
                    [ "organizations", organizationApiKey, "articles", "show", articleId ]

                TicketEdit organizationApiKey ticketId ->
                    [ "organizations", organizationApiKey, "tickets", ticketId ]

                OrganizationCreate ->
                    [ "organizations", "new" ]

                CategoryEdit organizationApiKey categoryId ->
                    [ "organizations", organizationApiKey, "categories", categoryId ]

                SignUp ->
                    [ "users", "sign_up" ]

                Login ->
                    [ "users", "sign_in" ]

                ForgotPassword ->
                    [ "users", "forgot_password" ]

                NotFound ->
                    []
    in
    "/" ++ String.join "/" pieces


fromLocation : Url -> Route
fromLocation location =
    case parse routeMatcher location of
        Just route ->
            route

        _ ->
            NotFound
