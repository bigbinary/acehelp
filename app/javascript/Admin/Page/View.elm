module Page.View exposing (adminHeader, adminLayout, logoutOption)

import Admin.Request.Helper exposing (ApiKey, NodeEnv)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.UserNotification as UserNotification
import Route exposing (..)


adminLayout :
    Html msg
    -> (UserNotification.Msg -> msg)
    -> Bool
    -> String
    -> UserNotification.Model
    -> List (Html msg)
    -> Html msg
adminLayout headerContent userNotificationMsg showLoading spinnerLabel notifications viewContent =
    div []
        [ headerContent
        , div
            []
            [ Html.map userNotificationMsg <| UserNotification.view showLoading spinnerLabel notifications ]
        , div [ class "container main-wrapper" ] viewContent
        ]


navLink : Route.Route -> String -> Route.Route -> String -> Html msg
navLink currentRoute matchText linkRoute linkName =
    a
        [ classList
            [ ( "nav-link", True )
            , ( "active", routeToString currentRoute |> String.contains matchText )
            ]
        , href (routeToString linkRoute)
        ]
        [ span [] [ text linkName ] ]


navLinkListItem : Route.Route -> String -> Route.Route -> String -> Html msg
navLinkListItem currentRoute matchText linkRoute linkName =
    li [ class "nav-item" ] [ navLink currentRoute matchText linkRoute linkName ]


adminHeader : ApiKey -> String -> Route.Route -> msg -> Html msg
adminHeader orgKey orgName currentRoute signOut =
    div []
        [ nav [ class "header navbar navbar-dark bg-primary navbar-expand flex-column flex-md-row" ]
            [ div [ class "container" ]
                [ ul
                    [ class "navbar-nav mr-auto mt-2 mt-lg-0 " ]
                    [ li [ class "nav-item" ]
                        [ span
                            [ classList
                                [ ( "navbar-brand", True ) ]
                            ]
                            [ span [] [ text orgName ] ]
                        ]
                    ]
                , navLinkListItem currentRoute "/articles" (Route.ArticleList orgKey) "Articles"
                , navLinkListItem currentRoute "/urls" (Route.UrlList orgKey) "URLs"
                , navLinkListItem currentRoute "/categories" (Route.CategoryList orgKey) "Categories"
                , navLinkListItem currentRoute "/tickets" (Route.TicketList orgKey) "Tickets"
                , navLinkListItem currentRoute "/feedback" (Route.FeedbackList orgKey) "Feedbacks"
                , navLinkListItem currentRoute "/team" (Route.TeamList orgKey) "Team"
                , navLinkListItem currentRoute "/settings" (Route.Settings orgKey) "Settings"
                ]
            , ul [ class "navbar-nav ml-auto" ]
                [ li [ class "nav-item " ]
                    [ button [ class "nav-link sign-out", onClick signOut ]
                        [ text "Logout" ]
                    ]
                ]
            ]
        , hamBurgerMenu
        ]


logoutOption : msg -> Html msg
logoutOption signOut =
    nav [ class "header navbar navbar-dark bg-primary navbar-expand flex-column flex-md-row" ]
        [ div [ class "container" ]
            [ ul [ class "navbar-nav ml-auto" ]
                [ li [ class "nav-item " ]
                    [ button [ class "nav-link sign-out", onClick signOut ]
                        [ text "Logout" ]
                    ]
                ]
            ]
        ]


hamBurgerMenu =
    nav
        [ class "navbar navbar-inverse navbar-static-top"
        , attribute "role" "navigation"
        ]
        [ div
            [ class "container" ]
            [ div
                [ class "navbar-header" ]
                [ button
                    [ class "navbar-toggle collapsed"
                    , attribute "data-toggle" "collapse"
                    , attribute "data-target" "#bs-example-navbar-collapse-1"
                    ]
                    [ span
                        [ class "sr-only" ]
                        [ text "toggle" ]
                    , span
                        [ class "icon-bar" ]
                        []
                    , span
                        [ class "icon-bar" ]
                        []
                    ]
                ]
            , div
                [ class "collapse navbar-collapse"
                , id "bs-example-navbar-collapse-1"
                ]
                [ ul
                    [ class "nav navbar-nav" ]
                    [ li []
                        [ a [] [ text "org1" ] ]
                    , li []
                        [ a [] [ text "org2" ] ]
                    , li []
                        [ a [] [ text "org3" ] ]
                    ]
                ]
            ]
        ]
