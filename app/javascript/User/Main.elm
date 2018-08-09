module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Request.Helpers exposing (..)


-- MODEL


type alias Model =
    { name : String
    , email : String
    }


initModel : Model
initModel =
    { name = ""
    , email = ""
    }


init : ( Model, Cmd Msg )
init =
    ( initModel
    , Cmd.none
    )



-- UPDATE


type Msg
    = EmailInput String
    | NameInput String


update : Msg -> Model -> Model
update msg model =
    case msg of
        EmailInput email ->
            ({ model | email = email })

        NameInput name ->
            ({ model | name = name })


view : Model -> Html Msg
view model =
    div [ class "container" ]
        [ Html.form []
            [ div []
                [ label [] [ text "Name: " ]
                , input
                    [ type_ "text"
                    , placeholder "Name..."
                    , onInput NameInput
                    ]
                    []
                ]
            , div []
                [ label [] [ text "Email: " ]
                , input
                    [ type_ "email"
                    , placeholder "Email..."
                    , onInput EmailInput
                    ]
                    []
                ]
            , button [ type_ "submit", class "button primary" ] [ text "Save URL" ]
            ]
        ]



--main : Program Flags Model Msg
--main =
--    Navigation.programWithFlags OnLocationChange
--        { init = init
--        , update = update
--        , view = view
--        , subscriptions = subscriptions
--        }


main : Program Never Model Msg
main =
    Html.beginnerProgram
        { model = initModel
        , update = update
        , view = view
        }
