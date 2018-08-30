module Page.UserNotification exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Admin.Data.ReaderCmd exposing (..)
import Admin.Views.Common exposing (..)
import Process
import Reader
import Task
import Json.Encode exposing (string)


-- MODEL


type UserNotification
    = ErrorNotification String
    | SuccessNotification String
    | NoNotification


type alias Model =
    { notifications : List UserNotification
    , showLoading : Bool
    , spinnerLabel : String
    }


initModel : Model
initModel =
    { notifications = [], showLoading = False, spinnerLabel = "" }


init : ( Model, List (ReaderCmd Msg) )
init =
    ( initModel, [] )



-- UPDATE


type Msg
    = InsertNotification UserNotification
    | RemoveNotification UserNotification
    | ClearNotifications


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        InsertNotification notification ->
            ( { model | notifications = (List.append model.notifications [ notification ]) }
            , [ Unit <| Reader.Reader (always <| Task.perform (always (RemoveNotification notification)) <| Process.sleep 5000) ]
            )

        RemoveNotification notification ->
            ( { model | notifications = List.filter (not << isNotificationEqual notification) model.notifications }, [] )

        ClearNotifications ->
            ( { model | notifications = [] }, [] )


isNotificationEqual notificationA notificationB =
    getMessage notificationA == getMessage notificationB


getMessage notification =
    case notification of
        ErrorNotification msg ->
            msg

        SuccessNotification msg ->
            msg

        NoNotification ->
            ""



-- VIEW


notificationView : UserNotification -> Html Msg
notificationView userNotification =
    case userNotification of
        ErrorNotification message ->
            div [ class "alert alert-danger alert-dismissible" ]
                [ text message, button [ type_ "button", class "close", onClick (RemoveNotification userNotification) ] [ span [ property "innerHTML" (string "&times;") ] [] ] ]

        SuccessNotification message ->
            div [ class "alert alert-success alert-dismissible" ]
                [ text message, button [ type_ "button", class "close", onClick (RemoveNotification userNotification) ] [ span [ property "innerHTML" (string "&times;") ] [] ] ]

        NoNotification ->
            text ""


notificationsColoumn : List UserNotification -> Html Msg
notificationsColoumn notifications =
    div [ class "notifications-coloumn" ]
        (List.map notificationView notifications)


view model =
    div [ class "floating-notifications" ]
        [ case model.showLoading of
            True ->
                div [ class "spinner-notification" ] [ loadingIndicator model.spinnerLabel ]

            False ->
                text ""
        , notificationsColoumn model.notifications
        ]
