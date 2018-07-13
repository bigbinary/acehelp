module Route exposing (Route(..), fromLocation, modifyUrl)

import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), Parser, oneOf, parseHash, s, string)


-- ROUTING --


type Route
    = Home
    | Articles
    | Urls
    | Categories
    | Integrations


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map Home (s "")
        , Url.map Articles (s "articles")
        , Url.map Urls (s "urls")
        , Url.map Categories (s "categories")
        , Url.map Integrations (s "integrations")
        ]



-- INTERNAL --


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

                Articles ->
                    [ "articles" ]

                Urls ->
                    [ "urls" ]

                Categories ->
                    [ "categories" ]

                Integrations ->
                    [ "integrations" ]
    in
        "/admin" ++ String.join "/" pieces


modifyUrl : Route -> Cmd msg
modifyUrl =
    routeToString >> Navigation.modifyUrl


fromLocation : Location -> Maybe Route
fromLocation location =
    if String.isEmpty location.hash then
        Just Home
    else
        parseHash route location
