module Route exposing (Route(..), fromLocation, modifyUrl)

import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), Parser, oneOf, parsePath, s, string)


-- ROUTING --


type Route
    = ArticleList
    | ArticleCreate
    | CategoryList
    | CategoryCreate
    | UrlList
    | UrlCreate
    | Integration
    | Dashboard
    | NotFound


routeMatcher : Parser (Route -> a) a
routeMatcher =
    oneOf
        [ Url.map Dashboard (s "")
        , Url.map ArticleList (s "articles")
        , Url.map UrlList (s "urls")
        , Url.map CategoryList (s "categories")
        , Url.map Integration (s "integrations")
        , Url.map ArticleCreate (s "articles" </> s "new")
        , Url.map UrlCreate (s "urls" </> s "new")
        , Url.map CategoryCreate (s "categories" </> s "new")
        ]



-- INTERNAL --


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Dashboard ->
                    []

                ArticleList ->
                    [ "articles" ]

                UrlList ->
                    [ "urls" ]

                CategoryList ->
                    [ "categories" ]

                Integration ->
                    [ "integrations" ]

                ArticleCreate ->
                    [ "articles", "new" ]

                UrlCreate ->
                    [ "urls", "new" ]

                CategoryCreate ->
                    [ "categories", "new" ]

                NotFound ->
                    []
    in
        "/admin" ++ String.join "/" pieces


modifyUrl : Route -> Cmd msg
modifyUrl =
    routeToString >> Navigation.modifyUrl


fromLocation : Location -> Route
fromLocation location =
    case (parsePath routeMatcher location) of
        Just route ->
            route

        _ ->
            NotFound
