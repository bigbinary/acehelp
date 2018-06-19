module Page.Article.Create exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Data.ArticleData exposing (..)
import Http
import Json.Encode as JE
import Json.Decode as JD exposing (field)
import Request.ArticleRequest exposing (..)


-- Model


type alias Model =
    { article : Maybe Article
    , title : String
    , titleError : Maybe String
    , desc : String
    , descError : Maybe String
    , keywords : String
    , keywordError : Maybe String
    , articleId : ArticleId
    , error : Maybe String
    }


initModel : Model
initModel =
    { article = Nothing
    , title = ""
    , titleError = Nothing
    , desc = ""
    , descError = Nothing
    , keywords = ""
    , keywordError = Nothing
    , articleId = 0
    , error = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( initModel
    , Cmd.none
    )



-- Update


type Msg
    = NewArticle
    | ShowArticle ArticleId
    | TitleInput String
    | DescInput String
    | KeywordsInput String
    | SaveArticle
    | SaveArticleResponse (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TitleInput title ->
            ( { model | title = title }, Cmd.none )

        DescInput desc ->
            ( { model | desc = desc }, Cmd.none )

        KeywordsInput keywords ->
            ( { model | keywords = keywords }, Cmd.none )

        SaveArticle ->
            let
                validArticleModel =
                    validate model
            in
                if isValid validArticleModel then
                    save validArticleModel
                else
                    ( model, Cmd.none )

        SaveArticleResponse (Ok id) ->
            ( { model
                | title = ""
                , titleError = Nothing
                , desc = ""
                , descError = Nothing
                , keywords = ""
                , keywordError = Nothing
              }
            , Cmd.none
            )

        SaveArticleResponse (Err error) ->
            let
                errorMessage =
                    case error of
                        Http.BadStatus response ->
                            response.body

                        _ ->
                            "Error while creating article"
            in
                ( { model
                    | error = Just errorMessage
                  }
                , Cmd.none
                )

        _ ->
            ( model, Cmd.none )



-- View


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Html.form
            [ onSubmit SaveArticle ]
            [ div []
                [ label [] [ text "Title: " ]
                , input
                    [ placeholder "Title..."
                    , onInput TitleInput
                    , value model.title
                    , type_ "text"
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Description: " ]
                , textarea
                    [ placeholder "Short description about article..."
                    , onInput DescInput
                    , value model.desc
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Keywords: " ]
                , input
                    [ placeholder "Keywords..."
                    , onInput KeywordsInput
                    , value model.keywords
                    , type_ "text"
                    ]
                    []
                ]
            , div []
                [ button
                    [ type_ "submit"
                    , class "button primary"
                    ]
                    [ text "Submit" ]
                ]
            ]
        ]


url : String
url =
    "http://localhost:3000/article"


articleEncoder : Model -> JE.Value
articleEncoder { title, desc } =
    JE.object
        [ ( "title", JE.string title )
        , ( "desc", JE.string desc )
        ]


save : Model -> ( Model, Cmd Msg )
save model =
    let
        request =
            requestCreateArticle "dev" "3c60b69a34f8cdfc76a0" (articleEncoder model)

        cmd =
            Http.send SaveArticleResponse request
    in
        ( model, cmd )


post : String -> List Http.Header -> Http.Body -> JD.Decoder a -> Http.Request a
post url headers body decoder =
    Http.request
        { method = "POST"
        , headers = headers
        , url = url
        , body = body
        , expect = Http.expectJson decoder
        , timeout = Nothing
        , withCredentials = False
        }


validate : Model -> Model
validate model =
    model
        |> validateTitle
        |> validateDesc
        |> validateKeyword


validateTitle : Model -> Model
validateTitle model =
    if String.isEmpty model.title then
        { model
            | titleError =
                Just "Title should be present"
        }
    else
        { model
            | titleError = Nothing
        }


validateDesc : Model -> Model
validateDesc model =
    if String.isEmpty model.desc then
        { model
            | descError =
                Just "Desc is required"
        }
    else
        { model
            | descError = Nothing
        }


validateKeyword : Model -> Model
validateKeyword model =
    if String.isEmpty model.keywords then
        { model
            | keywordError =
                Just "Keyword is required"
        }
    else
        { model
            | keywordError = Nothing
        }


isValid : Model -> Bool
isValid model =
    model.titleError
        == Nothing
        && model.descError
        == Nothing
        && model.keywordError
        == Nothing



--createArticleRequest : Model -> Cmd Msg
--createArticleRequest model =
