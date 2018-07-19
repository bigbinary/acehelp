module Page.Category.List exposing (..)

import Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Navigation exposing (..)
import Route
import Page.Category.Create as CategoryCreate
import Data.CategoryData exposing (..)
import Request.CategoryRequest exposing (..)
import Data.CommonData exposing (Error)


-- MODEL


type alias Model =
    { categoryList : CategoryList
    , errors : Error
    }


initModel : Model
initModel =
    { categoryList = { categories = [] }
    , errors = Nothing
    }


init : ( Model, Cmd Msg )
init =
    ( initModel
    , fetchCategories
    )



-- UPDATE


type Msg
    = CategoriesLoaded (Result Http.Error CategoryList)
    | Navigate Route.Route


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

        Navigate page ->
            model ! [ Navigation.newUrl (Route.routeToString page) ]



-- VIEW


view : Model -> Html Msg
view model =
    div
        []
        [ div
            [ class "buttonDiv" ]
            [ Html.a
                [ onClick (Navigate <| Route.CategoryCreate)
                , class "button primary"
                ]
                [ text "New Category" ]
            ]
        , div
            []
            (List.map
                (\category ->
                    categoryRow category
                )
                model.categoryList.categories
            )
        ]


categoryRow : Category -> Html Msg
categoryRow category =
    div []
        [ text category.name ]


fetchCategories : Cmd Msg
fetchCategories =
    let
        request =
            requestCategories "dev" "3c60b69a34f8cdfc76a0"

        cmd =
            Http.send CategoriesLoaded request
    in
        cmd
