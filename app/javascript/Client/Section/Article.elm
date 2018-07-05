module Section.Article exposing (init, Model, view, defaultModel, Msg, update)

import Data.Article exposing (..)
import Data.ContactUs exposing (GQLDataContact, encodeContactUs, decodeGQLDataContact)
import Request.Article exposing (..)
import Request.Helpers exposing (ApiKey, Context, NodeEnv, graphqlUrl)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Task
import Reader exposing (Reader)
import FontAwesome.Solid as SolidIcon
import Json.Encode as Encode
import Json.Decode as Decode


-- MODEL


type alias FeedbackForm =
    { comment : String
    , email : String
    , name : String
    }


type FeedBack
    = Positive
    | Negative
    | FeedbackSent
    | NoFeedback
    | ErroredFeedback


type alias Model =
    { article : Article
    , feedback : FeedBack
    , feedbackForm : Maybe FeedbackForm
    }


init : Reader ( NodeEnv, ApiKey, Context, ArticleId ) (Task.Task Http.Error ArticleResponse)
init =
    requestArticle


defaultModel : Article -> Model
defaultModel article =
    { article = article
    , feedback = NoFeedback
    , feedbackForm = Nothing
    }


emptyForm : FeedbackForm
emptyForm =
    { comment = ""
    , email = ""
    , name = ""
    }



-- UPDATE


type Msg
    = FeedbackSelected FeedBack
    | SendFeedback
    | Vote (Result Http.Error String)
    | SentFeedbackResponse (Result Http.Error GQLDataContact)
    | NameInput String
    | EmailInput String
    | CommentInput String


httpVote : Encode.Value -> Decode.Decoder String -> NodeEnv -> Cmd Msg
httpVote encode decode env =
    Http.send Vote <| Http.post (graphqlUrl env) (Http.jsonBody encode) decode


update : NodeEnv -> Msg -> Model -> ( Model, Cmd Msg )
update env msg model =
    case msg of
        FeedbackSelected feedback ->
            case feedback of
                Positive ->
                    ( { model | feedback = feedback }, httpVote (encodeUpvote model.article.id) decodeUpvote env )

                Negative ->
                    ( { model | feedback = feedback, feedbackForm = Just emptyForm }, httpVote (encodeDownvote model.article.id) decodeDownvote env )

                _ ->
                    ( { model | feedback = feedback }, Cmd.none )

        SendFeedback ->
            ( { model | feedback = FeedbackSent }
            , Maybe.withDefault Cmd.none <|
                Maybe.map
                    (\form ->
                        Http.send SentFeedbackResponse <|
                            Http.post (graphqlUrl env) (Http.jsonBody (encodeContactUs { name = form.name, email = form.email, message = form.comment })) decodeGQLDataContact
                    )
                    model.feedbackForm
            )

        Vote _ ->
            ( model, Cmd.none )

        SentFeedbackResponse (Ok response) ->
            case response.data.addContact.errors of
                [] ->
                    ( model, Cmd.none )

                _ ->
                    ( { model | feedback = ErroredFeedback }, Cmd.none )

        SentFeedbackResponse (Err response) ->
            ( { model | feedback = ErroredFeedback }, Cmd.none )

        NameInput name ->
            let
                newForm =
                    Maybe.map (\currentForm -> { currentForm | name = name }) model.feedbackForm
            in
                ( { model | feedbackForm = newForm }, Cmd.none )

        EmailInput email ->
            let
                newForm =
                    Maybe.map (\currentForm -> { currentForm | email = email }) model.feedbackForm
            in
                ( { model | feedbackForm = newForm }, Cmd.none )

        CommentInput comment ->
            let
                newForm =
                    Maybe.map (\currentForm -> { currentForm | comment = comment }) model.feedbackForm
            in
                ( { model | feedbackForm = newForm }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    let
        article =
            model.article

        feebackView =
            case model.feedback of
                Positive ->
                    positiveView

                Negative ->
                    negativeView

                NoFeedback ->
                    didThisHelpView

                FeedbackSent ->
                    feedbackSentView model

                ErroredFeedback ->
                    erroredFeedBack
    in
        div [ id "content-wrapper" ]
            [ div [ class "article-wrapper" ]
                [ h1 [] [ text article.title ]
                , div [ class "article-content" ]
                    [ p [] [ text article.content ]
                    ]
                , feebackView
                ]
            ]


didThisHelpView : Html Msg
didThisHelpView =
    div [ class "did-this-help" ]
        [ span [] [ text "Did this help?" ]
        , div [ class "thumbs thumbs-up", onClick (FeedbackSelected Positive) ] [ SolidIcon.thumbs_up ]
        , div [ class "thumbs thumbs-down", onClick (FeedbackSelected Negative) ] [ SolidIcon.thumbs_down ]
        ]


positiveView : Html msg
positiveView =
    div [ class "did-this-help" ]
        [ span [] [ text "Great! Love it!" ] ]


negativeView : Html Msg
negativeView =
    div [ class "did-this-help article-feedback" ]
        [ span []
            [ text "Please tell us what you are looking for."
            , text " If you enter your email then this would create a support ticket and we would get back to you soon"
            ]
        , textarea [ placeholder "Your comments", onInput CommentInput ] []
        , input [ type_ "text", placeholder "Your Email (optional)", onInput EmailInput ] []
        , input [ type_ "text", placeholder "Your Name (optional)", onInput NameInput ] []
        , div []
            [ div
                [ class "regular-button"
                , style [ ( "background-color", "rgb(60, 170, 249)" ) ]
                , onClick SendFeedback
                ]
                [ text "Submit" ]
            ]
        ]


feedbackSentView : Model -> Html msg
feedbackSentView model =
    div [ class "did-this-help" ]
        [ Maybe.withDefault
            (text "Something went wrong! Please try again")
          <|
            Maybe.map
                (\feedbackform ->
                    case feedbackform.email of
                        "" ->
                            text "Thanks for your feedback. We will try to improve this documenet"

                        _ ->
                            text "Support ticket has been created. Someone will get back to you soon. Thanks"
                )
                model.feedbackForm
        ]


erroredFeedBack : Html msg
erroredFeedBack =
    div [ class "did-this-help" ]
        [ (text "Something went wrong! Please try again") ]
