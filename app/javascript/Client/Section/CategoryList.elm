module Section.CategoryList exposing (init, initAnim, Msg(..), Model, view, getCategoryWithId)

import Data.Category exposing (..)
import Request.Category exposing (..)
import Request.Helpers exposing (ApiKey, Context, NodeEnv)
import Views.Container exposing (popInInitialAnim)
import Html exposing (..)
import Html.Events exposing (onClick)
import Html.Attributes exposing (id, class)
import Http
import Task
import Animation
import Reader
import FontAwesome.Solid as SolidIcon


-- MODEL


type alias Model =
    List Category


init : Reader.Reader ( NodeEnv, ApiKey ) (Task.Task Http.Error Categories)
init =
    requestCategories


initAnim : Animation.State
initAnim =
    Animation.style popInInitialAnim



-- UPDATE


type Msg
    = LoadCategory CategoryId



-- VIEW


view : Model -> Html Msg
view model =
    div [ id "content-wrapper" ]
        (List.map
            (\category ->
                div
                    [ onClick <| LoadCategory category.id
                    , class "clickable selectable-row"
                    ]
                    [ span [ class "row-icon" ] [ SolidIcon.file_alt ]
                    , span [ class "row-title" ] [ text category.name ]
                    ]
            )
            model
        )


getCategoryWithId : CategoryId -> Model -> Maybe Category
getCategoryWithId categoryId categoryList =
    List.head <|
        List.filter
            (\category -> category.id == categoryId)
            categoryList
