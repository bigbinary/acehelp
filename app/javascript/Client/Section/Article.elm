module Section.Article exposing (init, Model, view, defaultModel, Msg, update)

import Data.Common exposing (GQLError)
import Data.Article exposing (..)
import Request.Article exposing (..)
import Request.Helpers exposing (ApiKey, Context, NodeEnv, graphqlUrl)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Task
import Reader exposing (Reader)
import FontAwesome.Solid as SolidIcon
import Section.Helpers exposing (..)
import GraphQL.Client.Http as GQLClient


-- MODEL


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


init : ArticleId -> Reader ( NodeEnv, ApiKey ) (Task.Task GQLClient.Error Article)
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
    | Vote (Result GQLClient.Error ArticleSummary)
    | SentFeedbackResponse (Result GQLClient.Error (Maybe (List GQLError)))
    | NameInput String
    | EmailInput String
    | CommentInput String


update : Msg -> Model -> ( Model, SectionCmd Msg )
update msg model =
    case msg of
        FeedbackSelected feedback ->
            case feedback of
                Positive ->
                    ( { model | feedback = feedback }, Just <| Reader.map (Task.attempt Vote) <| requestUpvoteMutation model.article.id )

                Negative ->
                    ( { model | feedback = feedback, feedbackForm = Just emptyForm }, Just <| Reader.map (Task.attempt Vote) <| requestDownvoteMutation model.article.id )

                _ ->
                    ( { model | feedback = feedback }, Nothing )

        SendFeedback ->
            ( { model | feedback = FeedbackSent }
            , Maybe.map
                (\form ->
                    Reader.map (Task.attempt SentFeedbackResponse) <| requestFeedbackMutation form
                )
                model.feedbackForm
            )

        Vote _ ->
            ( model, Nothing )

        SentFeedbackResponse (Ok response) ->
            Maybe.withDefault ( model, Nothing ) <|
                Maybe.map
                    (\errors ->
                        case errors of
                            [] ->
                                ( model, Nothing )

                            _ ->
                                ( { model | feedback = ErroredFeedback }, Nothing )
                    )
                    response

        SentFeedbackResponse (Err response) ->
            ( { model | feedback = ErroredFeedback }, Nothing )

        NameInput name ->
            let
                newForm =
                    Maybe.map (\currentForm -> { currentForm | name = name }) model.feedbackForm
            in
                ( { model | feedbackForm = newForm }, Nothing )

        EmailInput email ->
            let
                newForm =
                    Maybe.map (\currentForm -> { currentForm | email = email }) model.feedbackForm
            in
                ( { model | feedbackForm = newForm }, Nothing )

        CommentInput comment ->
            let
                newForm =
                    Maybe.map (\currentForm -> { currentForm | comment = comment }) model.feedbackForm
            in
                ( { model | feedbackForm = newForm }, Nothing )



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
        [ span [ class "text-label" ] [ text "Did this help?" ]
        , div [ class "thumbs thumbs-up", onClick (FeedbackSelected Positive) ] [ SolidIcon.thumbs_up ]
        , div [ class "thumbs thumbs-down", onClick (FeedbackSelected Negative) ] [ SolidIcon.thumbs_down ]
        ]


positiveView : Html msg
positiveView =
    div [ class "did-this-help" ]
        [ span [ class "text-label" ] [ text "Great! Love it!" ] ]


negativeView : Html Msg
negativeView =
    div [ class "did-this-help article-feedback" ]
        [ span [ class "text-label" ]
            [ text "Please tell us what you are looking for."
            , text " If you enter your email then this would create a support ticket and we would get back to you soon"
            ]
        , textarea [ class "comment-box", placeholder "Your comments", onInput CommentInput ] []
        , input [ class "text-input", type_ "text", placeholder "Your Email (optional)", onInput EmailInput ] []
        , input [ class "text-input", type_ "text", placeholder "Your Name (optional)", onInput NameInput ] []
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
