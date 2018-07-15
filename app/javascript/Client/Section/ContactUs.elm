module Section.ContactUs exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (class, classList, id, type_, placeholder, style, defaultValue)
import Html.Events exposing (onClick, onInput)
import Data.ContactUs exposing (RequestMessage, ResponseMessage, decodeMessage)
import Json.Decode
import Views.Style exposing (tickShape)
import Regex exposing (Regex)


-- MODEL


type UserNotification
    = ErrorNotification String
    | MessageNotification String
    | NoNotification


type Field
    = Field (Maybe String) String


type alias Model =
    { name : Field
    , email : Field
    , message : Field
    , userNotification : UserNotification
    }


init : String -> String -> Model
init name email =
    { name = Field Nothing name
    , email = Field Nothing email
    , message = Field Nothing ""
    , userNotification = NoNotification
    }



-- UPDATE


type Msg
    = SendMessage
    | RequestMessageCompleted (Result Http.Error ResponseMessage)
    | NameInput String
    | EmailInput String
    | MessageInput String


fieldValue : Field -> String
fieldValue (Field err value) =
    value


fieldError : Field -> Maybe String
fieldError (Field err value) =
    err


isFieldErrored : Field -> Bool
isFieldErrored field =
    case (fieldError field) of
        Just _ ->
            True

        Nothing ->
            False


isModelSubmittable : Model -> Bool
isModelSubmittable model =
    not (isFieldErrored model.name) && not (isFieldErrored model.email) && not (isFieldErrored model.message)


contramapField : (Maybe String -> Maybe String) -> Field -> Field
contramapField mapper (Field err value) =
    Field (mapper err) value


modelToRequestMessage : Model -> RequestMessage
modelToRequestMessage model =
    { name = fieldValue model.name
    , email = fieldValue model.email
    , message = fieldValue model.message
    }


validEmail : Regex
validEmail =
    Regex.regex "^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        |> Regex.caseInsensitive


isValidEmail : Field -> Bool
isValidEmail =
    Regex.contains validEmail << fieldValue


validateBlankField : Field -> String -> Field
validateBlankField (Field err value) errorMessage =
    case value of
        "" ->
            Field (Just errorMessage) value

        _ ->
            Field err value


validateModel : Model -> Model
validateModel model =
    let
        { name, email, message } =
            model

        validatedName =
            validateBlankField name "Please enter your Name"

        validatedEmail =
            validateBlankField email "Please enter your Email"
                |> contramapField
                    (\err ->
                        case err of
                            Just err ->
                                Just err

                            Nothing ->
                                case (isValidEmail email) of
                                    True ->
                                        Nothing

                                    False ->
                                        Just "Please enter a valid email"
                    )

        validatedMessage =
            validateBlankField message "Message cannot be blank"
    in
        ({ model | name = validatedName, email = validatedEmail, message = validatedMessage })


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
                ( { model | message = Field Nothing "", userNotification = notification }, Cmd.none )

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

        SendMessage ->
            ( validateModel model, Cmd.none )

        NameInput name ->
            ( { model | name = Field Nothing name }, Cmd.none )

        EmailInput email ->
            ( { model | email = Field Nothing email }, Cmd.none )

        MessageInput message ->
            ( { model | message = Field Nothing message }, Cmd.none )



-- VIEW


successView : String -> Html msg
successView message =
    div [ id "contact-us-success", class "centered-content" ]
        [ div [ class "tick" ] [ tickShape "100" "100" ]
        , div [ class "text friendlyMessage" ] [ text message ]
        ]


formView : Model -> Maybe String -> Html Msg
formView model message =
    let
        userNotificationDom =
            Maybe.map
                (\message -> div [ classList [ ( "user-notification", True ), ( "error", True ) ] ] [ text message ])
                message
                |> Maybe.withDefault (text "")

        fieldErrorDom field =
            fieldError field
                |> Maybe.map
                    (\msg ->
                        span [ class "errored" ] [ text msg ]
                    )
                |> Maybe.withDefault (text "")
    in
        div [ id "contact-us-wrapper" ]
            [ userNotificationDom
            , h2 [] [ text "Send us a message" ]
            , div [ class "contact-user" ]
                [ span [ class "contact-name" ]
                    [ input
                        [ type_ "text"
                        , placeholder "Your Name"
                        , onInput NameInput
                        , defaultValue (fieldValue model.name)
                        ]
                        []
                    , fieldErrorDom model.name
                    ]
                , span [ class "contact-email" ]
                    [ input
                        [ type_ "text"
                        , placeholder "Your Email"
                        , onInput EmailInput
                        , defaultValue (fieldValue model.email)
                        ]
                        []
                    , fieldErrorDom model.email
                    ]
                ]

            -- , input [ type_ "text", class "contact-subject", placeholder "Subject" ] []
            , span [ class "contact-message" ] [ textarea [ placeholder "How can we help?", onInput MessageInput ] [], fieldErrorDom model.message ]
            , div [ class "regular-button", style [ ( "background-color", "rgb(60, 170, 249)" ) ], onClick SendMessage ] [ text "Send Message" ]
            ]


view : Model -> Html Msg
view model =
    let
        contactUsDom =
            case model.userNotification of
                MessageNotification message ->
                    successView message

                NoNotification ->
                    formView model Nothing

                ErrorNotification message ->
                    formView model (Just message)
    in
        div [ id "content-wrapper" ] [ contactUsDom ]
