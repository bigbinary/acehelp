module Section.ContactUs exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (class, id, type_, placeholder, style)
import Html.Events exposing (onClick)
import Request.ContactUs exposing (requestContactUs)
import Task
import Reader
import Data.ContactUs exposing (ResponseMessage)


-- MODEL


type UserNotification
    = ErrorNotification String
    | MessageNotification String
    | NoNotification


type alias Model =
    { name : String
    , email : String

    -- , title : String
    , message : String
    , userNotification : UserNotification
    }


init : Model
init =
    { name = ""
    , email = ""

    -- , title = ""
    , message = ""
    , userNotification = NoNotification
    }



-- UPDATE


type Msg
    = SendMessage Model
    | RequestMessageCompleted (Result Http.Error ResponseMessage)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestMessageCompleted (Ok message) ->
            ( init, Cmd.none )

        RequestMessageCompleted (Err error) ->
            ( init, Cmd.none )

        SendMessage model ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    let
        userNotificationDom =
            case model.userNotification of
                ErrorNotification message ->
                    div [ class "user-notification" ] [ text message ]

                MessageNotification message ->
                    div [ class "user-notification" ] [ text message ]

                NoNotification ->
                    text ""
    in
        div [ id "content-wrapper" ]
            [ userNotificationDom
            , div [ id "contact-us-wrapper" ]
                [ h2 [] [ text "Send us a message" ]
                , div [ class "contact-user" ]
                    [ span [ class "contact-name" ] [ input [ type_ "text", placeholder "Your Name" ] [] ]
                    , span [ class "contact-email" ] [ input [ type_ "text", placeholder "Your Email" ] [] ]
                    ]

                -- , input [ type_ "text", class "contact-subject", placeholder "Subject" ] []
                , textarea [ placeholder "How can we help?" ] []
                , div [ class "regular-button", style [ ( "background-color", "rgb(60, 170, 249)" ) ], onClick (SendMessage model) ] [ text "Send Message" ]
                ]
            ]
