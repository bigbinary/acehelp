module Page.View exposing (adminHeader, adminLayout, hamBurgerMenu, logoutOption)

import Admin.Data.Organization exposing (Organization)
import Admin.Request.Helper exposing (ApiKey, NodeEnv)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.UserNotification as UserNotification
import Route exposing (..)
import Views.FontAwesome as FontAwesome exposing (..)


adminLayout :
    { headerContent : Html msg
    , userNotificationMsg : UserNotification.Msg -> msg
    , showLoading : Bool
    , spinnerLabel : String
    , notifications : UserNotification.Model
    , viewContent : List (Html msg)
    }
    -> Html msg
adminLayout { headerContent, userNotificationMsg, showLoading, spinnerLabel, notifications, viewContent } =
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


adminHeader : { orgKey : ApiKey, orgName : String, currentRoute : Route.Route, onMenuClick : msg, onSignOut : msg } -> Html msg
adminHeader { orgKey, orgName, currentRoute, onMenuClick, onSignOut } =
    nav [ class "header navbar navbar-dark bg-primary navbar-expand flex-column flex-md-row" ]
        [ div [ class "container" ]
            [ ul
                [ class "navbar-nav mr-auto mt-2 mt-lg-0 " ]
                [ li [ class "nav-item" ]
                    [ span
                        [ class "navbar-brand"
                        ]
                        [ span [ onClick onMenuClick ]
                            [ span
                                [ class "hamburger-button d-inline-block align-self-center" ]
                                [ FontAwesome.bars ]
                            , span [ class "org-name" ] [ text orgName ]
                            ]
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
                    [ button [ class "nav-link sign-out", onClick onSignOut ]
                        [ text "Logout" ]
                    ]
                ]
            ]
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


hamBurgerMenu : List Organization -> (Organization -> msg) -> msg -> Html msg
hamBurgerMenu organizationList updateOrganization onCloseMenu =
    div [ class "menu-overlay" ]
        [ div [ class "screen-overlay" ] []
        , div
            [ class "hamburger-menu nav flex-column" ]
          <|
            List.concat
                [ [ div
                        [ class "nav-link menu-title" ]
                        [ h4 [] [ text "Select an Organization" ]
                        , h4 [ class "menu-close", onClick onCloseMenu ] [ text "x" ]
                        ]
                  ]
                , List.map
                    (\org ->
                        span [ class "nav-link", onClick (updateOrganization org) ] [ text org.name ]
                    )
                    organizationList
                ]
        ]
