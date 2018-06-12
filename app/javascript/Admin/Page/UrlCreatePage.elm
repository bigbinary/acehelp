module Page.UrlCreatePage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)


-- MODEL


type alias Model =
    { url : String
    , urlTitle : String
    }


init : ( Model, Cmd Msg )
init =
    ( { url = ""
      , urlTitle = ""
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = UrlInput String
    | TitleInput String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UrlInput url ->
            ( { model | url = url }, Cmd.none )

        TitleInput title ->
            ( { model | urlTitle = title }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Html.form []
            [ div []
                [ label [] [ text "URL: " ]
                , input
                    [ type_ "text"
                    , placeholder "Url..."
                    , value model.url
                    , onInput UrlInput
                    ]
                    []
                ]
            , div []
                [ label [] [ text "URL Title: " ]
                , input
                    [ type_ "text"
                    , placeholder "Title..."
                    , value model.urlTitle
                    , onInput TitleInput
                    ]
                    []
                ]
            , button [ type_ "submit", class "button primary" ] [ text "Save URL" ]
            ]
        ]
