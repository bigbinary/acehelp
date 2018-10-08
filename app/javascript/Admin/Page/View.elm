module Page.View exposing
    ( adminHeader
    , adminLayout
    , hamBurgerMenu
    , logoutOption
    , pendingActionsConfirmationDialog
    )

import Admin.Data.Common exposing (..)
import Admin.Data.Organization exposing (Organization)
import Admin.Request.Helper exposing (ApiKey, NodeEnv)
import Admin.Views.Common exposing (..)
import Dialog
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Page.UserNotification as UserNotification
import PendingActions exposing (PendingActions)
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


hamBurgerMenu : { organizationList : List Organization, toUpdatedRoute : Organization -> Route, onCloseMenu : msg } -> Html msg
hamBurgerMenu { organizationList, toUpdatedRoute, onCloseMenu } =
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
                        a [ class "nav-link", href <| routeToString <| toUpdatedRoute <| org ] [ text org.name ]
                    )
                    organizationList
                , [ a [ class "nav-link menu-add-org", href <| routeToString <| OrganizationCreate ] [ h5 [] [ text "+ Add" ] ] ]
                ]
        ]


pendingActionsConfirmationDialog : Acknowledgement msg -> PendingActions -> msg -> Html msg
pendingActionsConfirmationDialog acknowledgement pendingActions onDeclineMsg =
    let
        pendingActionMessages =
            PendingActions.messages pendingActions
                |> List.map (\message -> li [] [ strong [] [ text message ] ])

        body =
            div []
                [ p []
                    [ text "There are some pending actions as follows. Are you sure you want to ignore them?"
                    ]
                , ul [] pendingActionMessages
                ]
    in
    Dialog.view <|
        case acknowledgement of
            Yes onAcceptMsg ->
                Just
                    (dialogConfig
                        { onAccept = onAcceptMsg
                        , onDecline = onDeclineMsg
                        , title = "Pending Actions"
                        , body = body
                        }
                    )

            No ->
                Nothing
