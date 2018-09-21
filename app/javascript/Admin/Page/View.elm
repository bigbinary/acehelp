module Page.View exposing (adminHeader, adminLayout, errorAlert, logoutOption)

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


adminHeader : ApiKey -> String -> Route.Route -> msg -> Html msg
adminHeader orgKey orgName currentRoute signOut =
    nav [ class "header navbar navbar-dark bg-primary navbar-expand flex-column flex-md-row" ]
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
                , li [ class "nav-item" ]
                    [ a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active"
                              , (currentRoute
                                    == Route.ArticleList
                                        orgKey
                                )
                                    || (currentRoute == Route.ArticleCreate orgKey)
                              )
                            ]
                        , href <| routeToString <| Route.ArticleList orgKey
                        ]
                        [ span [] [ text "Articles" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active"
                              , (currentRoute == Route.UrlList orgKey)
                                    || (currentRoute == Route.UrlCreate orgKey)
                              )
                            ]
                        , href <| routeToString <| Route.UrlList orgKey
                        ]
                        [ span [] [ text "URL" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active"
                              , (currentRoute == Route.CategoryList orgKey)
                                    || (currentRoute == Route.CategoryCreate orgKey)
                              )
                            ]
                        , href <| routeToString <| Route.CategoryList orgKey
                        ]
                        [ span [] [ text "Category" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active", currentRoute == Route.TicketList orgKey )
                            ]
                        , href <| routeToString <| Route.TicketList orgKey
                        ]
                        [ span [] [ text "Ticket" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active", currentRoute == Route.FeedbackList orgKey )
                            ]
                        , href <| routeToString <| Route.FeedbackList orgKey
                        ]
                        [ span [] [ text "Feedback" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active", currentRoute == Route.TeamList orgKey )
                            ]
                        , href <| routeToString <| Route.TeamList orgKey
                        ]
                        [ span [] [ text "Team" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active", currentRoute == Route.Settings orgKey )
                            ]
                        , href <| routeToString <| Route.Settings orgKey
                        ]
                        [ span [] [ text "Settings" ] ]
                    ]
                ]
            , ul [ class "navbar-nav ml-auto" ]
                [ li [ class "nav-item " ]
                    [ button [ class "nav-link sign-out", onClick signOut ]
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


errorAlert : List String -> Html msg
errorAlert errors =
    case errors of
        [] ->
            text ""

        _ ->
            div
                [ class "alert alert-danger alert-dismissible fade show"
                , attribute "role" "alert"
                ]
                [ text <| String.join ", " errors
                ]
