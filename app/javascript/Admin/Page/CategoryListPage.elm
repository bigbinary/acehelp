module Page.CategoryListPage exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)


--import Html.Events exposing (..)

import Http


-- MODEL


type alias Model =
    { categoryList : String
    , errors : Maybe String
    }


type alias Category =
    { id : Int
    , name : String
    }


init : ( Model, Cmd Msg )
init =
    ( { categoryList = ""
      , errors = Nothing
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = CategoriesLoaded (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CategoriesLoaded (Ok categories) ->
            ( { model
                | categoryList = categories
              }
            , Cmd.none
            )

        CategoriesLoaded (Err error) ->
            let
                errorMsg =
                    case error of
                        Http.BadStatus response ->
                            response.body

                        _ ->
                            "Error while fetching category list"
            in
                ( { model
                    | errors = Just errorMsg
                  }
                , Cmd.none
                )



-- VIEW


view : Model -> Html Msg
view model =
    div
        []
        [ div
            [ style
                [ ( "float", "right" )
                ]
            ]
            [ a [ href "/admin/categories/new" ] [ text "New Category" ] ]
        , text "categories List page"
        ]
