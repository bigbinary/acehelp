module Page.View exposing (..)

import Admin.Request.Helper exposing (ApiKey, NodeEnv)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route exposing (..)
import Page.UserNotification as UserNotification


adminLayout : Html msg -> (UserNotification.Msg -> msg) -> Bool -> String -> UserNotification.Model -> List (Html msg) -> Html msg
adminLayout headerContent userNotificationMsg showLoading spinnerLabel notifications viewContent =
    div []
        [ headerContent
        , div
            []
            [ Html.map userNotificationMsg <| UserNotification.view showLoading spinnerLabel notifications ]
        , div [ class "container main-wrapper" ] viewContent
        ]


adminHeader : ApiKey -> String -> Route.Route -> (Route.Route -> msg) -> msg -> Html msg
adminHeader orgKey orgName currentRoute navigateTo signOut =
    nav [ class "header navbar navbar-dark bg-primary navbar-expand flex-column flex-md-row" ]
        [ div [ class "container" ]
            [ ul
                [ class "navbar-nav mr-auto mt-2 mt-lg-0 " ]
                [ li [ class "nav-item" ]
                    [ Html.a
                        [ classList
                            [ ( "navbar-brand", True ) ]
                        ]
                        [ span [] [ text orgName ] ]
                    ]
                , li [ class "nav-item" ]
                    [ Html.a
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
                        , onClick <| (navigateTo (Route.ArticleList orgKey))
                        ]
                        [ span [] [ text "Articles" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ Html.a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active"
                              , (currentRoute == Route.UrlList orgKey)
                                    || (currentRoute == Route.UrlCreate orgKey)
                              )
                            ]
                        , onClick <| navigateTo (Route.UrlList orgKey)
                        ]
                        [ span [] [ text "URL" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ Html.a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active"
                              , (currentRoute == Route.CategoryList orgKey)
                                    || (currentRoute == Route.CategoryCreate orgKey)
                              )
                            ]
                        , onClick <| navigateTo (Route.CategoryList orgKey)
                        ]
                        [ span [] [ text "Category" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ Html.a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active", currentRoute == Route.TicketList orgKey )
                            ]
                        , onClick <| navigateTo (Route.TicketList orgKey)
                        ]
                        [ span [] [ text "Ticket" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ Html.a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active", currentRoute == Route.FeedbackList orgKey )
                            ]
                        , onClick <| navigateTo (Route.FeedbackList orgKey)
                        ]
                        [ span [] [ text "Feedback" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ Html.a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active", currentRoute == Route.TeamList orgKey )
                            ]
                        , onClick <| navigateTo (Route.TeamList orgKey)
                        ]
                        [ span [] [ text "Team" ] ]
                    ]
                , li [ class "nav-item" ]
                    [ Html.a
                        [ classList
                            [ ( "nav-link", True )
                            , ( "active", currentRoute == Route.Settings orgKey )
                            ]
                        , onClick <| navigateTo (Route.Settings orgKey)
                        ]
                        [ span [] [ text "Settings" ] ]
                    ]
                ]
            , ul [ class "navbar-nav ml-auto" ]
                [ li [ class "nav-item " ]
                    [ Html.a [ class "nav-link", onClick signOut ]
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
                    [ Html.a [ class "nav-link", onClick signOut ]
                        [ text "Logout" ]
                    ]
                ]
            ]
        ]
