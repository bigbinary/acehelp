module Section.ContactUs exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (class, classList, id, type_, placeholder, style)
import Html.Events exposing (onClick, onInput)
import Data.ContactUs exposing (ResponseMessage, decodeMessage)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Decode exposing (string)


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
    | NameInput String
    | EmailInput String
    | MessageInput String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RequestMessageCompleted (Ok responseMessage) ->
            let
                { message, error } =
                    responseMessage

                notification =
                    case ( message, error ) of
                        ( Just userMessage, Nothing ) ->
                            MessageNotification userMessage

                        ( _, Just userMessage ) ->
                            ErrorNotification userMessage

                        ( Nothing, Nothing ) ->
                            NoNotification
            in
                ( { init | userNotification = notification }, Cmd.none )

        RequestMessageCompleted (Err error) ->
            let
                stringToUserNotification =
                    .error
                        >> Maybe.map ErrorNotification
                        >> Maybe.withDefault NoNotification

                resultToUserNotification result =
                    case result of
                        Ok error ->
                            stringToUserNotification error

                        Err error ->
                            NoNotification

                decode =
                    Json.Decode.decodeString decodeMessage

                errorMessage =
                    case error of
                        Http.BadPayload debugMsg response ->
                            resultToUserNotification <| decode <| Debug.log "badpayload" response.body

                        Http.BadStatus response ->
                            resultToUserNotification <| decode <| Debug.log "badstatus" response.body

                        _ ->
                            NoNotification
            in
                ( { model | userNotification = errorMessage }, Cmd.none )

        SendMessage model ->
            ( model, Cmd.none )

        NameInput name ->
            ( { model | name = name }, Cmd.none )

        EmailInput email ->
            ( { model | email = email }, Cmd.none )

        MessageInput message ->
            ( { model | message = message }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    let
        userNotificationDom =
            case model.userNotification of
                ErrorNotification message ->
                    div [ classList [ ( "user-notification", True ), ( "error", True ) ] ] [ text message ]

                MessageNotification message ->
                    div [ classList [ ( "user-notification", True ), ( "message", True ) ] ] [ text message ]

                NoNotification ->
                    text ""
    in
        div [ id "content-wrapper" ]
            [ userNotificationDom
            , div [ id "contact-us-wrapper" ]
                [ h2 [] [ text "Send us a message" ]
                , div [ class "contact-user" ]
                    [ span [ class "contact-name" ] [ input [ type_ "text", placeholder "Your Name", onInput NameInput ] [] ]
                    , span [ class "contact-email" ] [ input [ type_ "text", placeholder "Your Email", onInput EmailInput ] [] ]
                    ]

                -- , input [ type_ "text", class "contact-subject", placeholder "Subject" ] []
                , textarea [ placeholder "How can we help?", onInput MessageInput ] []
                , div [ class "regular-button", style [ ( "background-color", "rgb(60, 170, 249)" ) ], onClick (SendMessage model) ] [ text "Send Message" ]
                ]
            ]
