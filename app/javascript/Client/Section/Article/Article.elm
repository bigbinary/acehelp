module Section.Article.Article exposing (FeedBack(..), Model, Msg(..), didThisHelpView, emptyForm, erroredFeedBack, feedbackSentView, init, initModel, negativeView, positiveView, update, view)

import Data.Article exposing (..)
import Data.Common exposing (..)
import Data.ContactUs exposing (FeedbackForm)
import GraphQL.Client.Http as GQLClient
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Request.Article exposing (..)
import Request.ContactUs exposing (requestAddTicketMutation)
import Task
import Views.Error as Error
import Views.FontAwesome as FontAwesome exposing (..)



-- MODEL


type FeedBack
    = Positive
    | Negative
    | FeedbackSent
    | NoFeedback
    | ErroredFeedback


type alias Model =
    { article : Stuff Article GQLClient.Error
    , feedback : FeedBack
    , feedbackForm : Maybe FeedbackForm
    }


init : ArticleId -> ( Model, List (SectionCmd Msg) )
init articleId =
    ( initModel
    , [ Strict <| Reader.map (Task.attempt ArticleLoaded) (requestArticle articleId) ]
    )


initModel : Model
initModel =
    { article = None
    , feedback = NoFeedback
    , feedbackForm = Nothing
    }


emptyForm : ArticleId -> FeedbackForm
emptyForm articleId =
    { comment = ""
    , email = ""
    , name = ""
    , article_id = articleId
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
    | ArticleLoaded (Result GQLClient.Error Data.Article.Article)



--markFeedback: Msg -> Model -> Model


update : Msg -> Model -> ( Model, List (SectionCmd Msg) )
update msg model =
    case msg of
        ArticleLoaded (Ok article) ->
            ( { model | article = IsA article }, [] )

        ArticleLoaded (Err error) ->
            ( { model | article = Error error }, [] )

        FeedbackSelected feedback ->
            case model.article of
                IsA article ->
                    case feedback of
                        Positive ->
                            ( { model | feedback = feedback }
                            , [ Strict <|
                                    Reader.map (Task.attempt Vote) <|
                                        requestUpvoteMutation article.id
                              ]
                            )

                        Negative ->
                            ( { model
                                | feedback = feedback
                                , feedbackForm =
                                    Just
                                        (emptyForm article.id)
                              }
                            , [ Strict <|
                                    Reader.map (Task.attempt Vote) <|
                                        requestDownvoteMutation article.id
                              ]
                            )

                        _ ->
                            ( { model | feedback = feedback }, [] )

                _ ->
                    ( model, [] )

        SendFeedback ->
            ( { model | feedback = FeedbackSent }
            , Maybe.map
                (\form ->
                    case form.email of
                        "" ->
                            [ Strict <|
                                Reader.map (Task.attempt SentFeedbackResponse) <|
                                    requestAddFeedbackMutation form
                            ]

                        _ ->
                            [ Strict <|
                                Reader.map (Task.attempt SentFeedbackResponse) <|
                                    requestAddTicketMutation form
                            ]
                )
                model.feedbackForm
                |> Maybe.withDefault []
            )

        Vote _ ->
            ( model, [] )

        SentFeedbackResponse (Ok response) ->
            Maybe.withDefault ( model, [] ) <|
                Maybe.map
                    (\errors ->
                        case errors of
                            [] ->
                                ( model, [] )

                            _ ->
                                ( { model | feedback = ErroredFeedback }, [] )
                    )
                    response

        SentFeedbackResponse (Err response) ->
            ( { model | feedback = ErroredFeedback }, [] )

        NameInput name ->
            let
                newForm =
                    Maybe.map (\currentForm -> { currentForm | name = name })
                        model.feedbackForm
            in
            ( { model | feedbackForm = newForm }, [] )

        EmailInput email ->
            let
                newForm =
                    Maybe.map (\currentForm -> { currentForm | email = email })
                        model.feedbackForm
            in
            ( { model | feedbackForm = newForm }, [] )

        CommentInput comment ->
            let
                newForm =
                    Maybe.map (\currentForm -> { currentForm | comment = comment })
                        model.feedbackForm
            in
            ( { model | feedbackForm = newForm }, [] )



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
    case model.article of
        IsA articleItem ->
            div [ id "content-wrapper" ]
                [ div [ class "article-wrapper" ]
                    [ h1 [] [ text articleItem.title ]
                    , div [ class "article-content trix-content" ]
                        [ p [] [ text articleItem.content ]
                        ]
                    , feebackView
                    ]
                ]

        Error error ->
            Error.view error

        None ->
            text ""


didThisHelpView : Html Msg
didThisHelpView =
    div [ class "did-this-help" ]
        [ span [ class "text-label" ] [ text "Did this help?" ]
        , div
            [ class "thumbs thumbs-up"
            , onClick
                (FeedbackSelected
                    Positive
                )
            ]
            [ FontAwesome.thumbs_up ]
        , div
            [ class "thumbs thumbs-down"
            , onClick
                (FeedbackSelected
                    Negative
                )
            ]
            [ FontAwesome.thumbs_down ]
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
        , textarea
            [ class "comment-box"
            , placeholder "Your comments"
            , onInput CommentInput
            ]
            []
        , input
            [ class "text-input"
            , type_ "text"
            , placeholder "Your Email"
            , onInput EmailInput
            ]
            []
        , input
            [ class "text-input"
            , type_ "text"
            , placeholder "Your Name (optional)"
            , onInput NameInput
            ]
            []
        , div []
            [ div
                [ class "regular-button"
                , style "background-color" "rgb(60, 170, 249)"
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
        [ text "Something went wrong! Please try again" ]
