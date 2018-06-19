module Page.Category.Create exposing (..)

import Html exposing (..)


--import Html.Attributes exposing (..)
--import Html.Events exposing (..)

import Http


-- MODEL


type alias Model =
    { id : Int
    , name : String
    , errors : Maybe String
    }


initModel : Model
initModel =
    { id = 0
    , name = ""
    , errors = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( initModel
    , Cmd.none
    )



-- UPDATE


type Msg
    = SaveCategory
    | SaveCategoryResponse (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SaveCategory ->
            ( model, Cmd.none )

        SaveCategoryResponse (Ok id) ->
            ( { model
                | id = 0
                , name = ""
                , errors = Nothing
              }
            , Cmd.none
            )

        SaveCategoryResponse (Err error) ->
            let
                errorMsg =
                    case error of
                        Http.BadStatus response ->
                            response.body

                        _ ->
                            "Error while saving Category"
            in
                ( { model
                    | errors = Just errorMsg
                  }
                , Cmd.none
                )



-- VIEW


view : Model -> Html Msg
view model =
    div [] [ text "This is create category page" ]
