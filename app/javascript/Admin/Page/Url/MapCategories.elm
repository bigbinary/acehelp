module Page.Url.MapCategories exposing (Model, Msg(..), init, initModel, save, update, view)

import Admin.Data.Category exposing (..)
import Admin.Data.Common exposing (..)
import Admin.Data.ReaderCmd exposing (..)
import Admin.Data.Setting exposing (..)
import Admin.Data.Url exposing (..)
import Admin.Request.Category exposing (..)
import Admin.Request.Setting exposing (..)
import Admin.Request.Url exposing (..)
import Admin.Views.Common exposing (..)
import Field exposing (..)
import Field.ValidationResult exposing (..)
import GraphQL.Client.Http as GQLClient
import Helpers exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Reader exposing (Reader)
import Request.Helpers exposing (ApiKey, NodeEnv)
import Route
import Task exposing (Task)



-- MODEL


type alias Model =
    { errors : List String
    , success : Maybe String
    , urlId : UrlId
    , url : Maybe UrlData
    , categories : List (Option Category)
    }


initModel : Model
initModel =
    { errors = []
    , success = Nothing
    , url = Nothing
    , urlId = ""
    , categories = []
    }


init : UrlId -> ( Model, List (ReaderCmd Msg) )
init urlId =
    ( initModel
    , [ Strict <| Reader.map (Task.attempt UrlLoaded) (requestUrlById urlId)
      , Strict <| Reader.map (Task.attempt CategoriesLoaded) requestCategories
      ]
    )



-- UPDATE


type Msg
    = SaveUrl
    | SaveUrlResponse (Result GQLClient.Error UrlResponse)
    | UrlLoaded (Result GQLClient.Error (Maybe UrlData))
    | CategoriesLoaded (Result GQLClient.Error (Maybe (List Category)))
    | CategoryModified (Option CategoryId)


update : Msg -> Model -> ( Model, List (ReaderCmd Msg) )
update msg model =
    case msg of
        CategoriesLoaded (Ok receivedCategories) ->
            case receivedCategories of
                Just categories ->
                    ( { model
                        | categories =
                            selectItemsInList
                                (Maybe.withDefault [] <|
                                    Maybe.map (\url -> List.map (.id >> Selected) url.categories) model.url
                                )
                            <|
                                categoriesToOption categories
                      }
                    , []
                    )

                Nothing ->
                    ( model, [] )

        CategoriesLoaded (Err error) ->
            ( { model | errors = [ "There was an error while loading the Categories" ] }, [] )

        SaveUrl ->
            save model

        SaveUrlResponse (Ok response) ->
            case response.errors of
                Just errs ->
                    case errs of
                        [] ->
                            ( { model | success = Just "Successfully assigned Categories" }, [] )

                        _ ->
                            ( { model | errors = List.map .message errs }, [] )

                _ ->
                    ( model, [] )

        SaveUrlResponse (Err error) ->
            ( { model | errors = [ "An error occured while saving the Url" ] }, [] )

        UrlLoaded (Ok url) ->
            case url of
                Just urlData ->
                    ( { model
                        | url = url
                        , categories =
                            selectItemsInList
                                (List.map (.id >> Selected) urlData.categories)
                            <|
                                model.categories
                      }
                    , []
                    )

                Nothing ->
                    ( { model | errors = [ "There was an error while loading the url" ] }, [] )

        UrlLoaded (Err err) ->
            ( { model | errors = [ "There was an error while loading the url" ] }, [] )

        CategoryModified categoryId ->
            ( { model | categories = selectItemInList categoryId model.categories }, [] )


categoriesToOption : List Category -> List (Option Category)
categoriesToOption =
    List.map Unselected


optionsToCategoryIds : List (Option Category) -> List CategoryId
optionsToCategoryIds =
    List.filterMap
        (\option ->
            case option of
                Selected category ->
                    Just category.id

                Unselected category ->
                    Nothing
        )



-- VIEW


view : Model -> Html Msg
view model =
    let
        ( rule, pattern ) =
            model.url
                |> Maybe.map (\url -> ( url.url_rule, url.url_pattern ))
                |> Maybe.withDefault ( "", "" )
    in
    div [ class "url-container" ]
        [ errorView model.errors
        , successView model.success
        , h3 [] [ text <| rule ++ " " ++ pattern ]
        , div [ class "form-group" ]
            [ multiSelectMenu "Select Categories:"
                (List.map
                    (\category ->
                        case category of
                            Selected { id, name } ->
                                Selected { id = id, value = name }

                            Unselected { id, name } ->
                                Unselected { id = id, value = name }
                    )
                    model.categories
                )
                CategoryModified
            , button [ onClick SaveUrl, class "btn btn-primary" ] [ text "Save URL" ]
            ]
        ]


save : Model -> ( Model, List (ReaderCmd Msg) )
save model =
    ( model
    , Maybe.map
        (\urlData ->
            let
                newUrlData =
                    { id = urlData.id, categories = optionsToCategoryIds model.categories }
            in
            [ Strict <|
                Reader.map (Task.attempt SaveUrlResponse)
                    (updateCategoriesToUrl newUrlData)
            ]
        )
        model.url
        |> Maybe.withDefault []
    )
