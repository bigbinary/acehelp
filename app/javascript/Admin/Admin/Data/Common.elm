module Admin.Data.Common exposing
    ( Acknowledgement(..)
    , Error
    , Option(..)
    , Value
    , errorObject
    , errorsField
    , flattenErrors
    , selectItemInList
    , selectItemsInList
    , targetSelectedOptions
    )

import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Helpers exposing (maybeToList)
import Json.Decode as Json
import Json.Decode.Extra as JsonEx


type alias Value =
    { id : String
    , value : String
    }


type alias Error =
    { message : String }


type Option a
    = Selected a
    | Unselected a


type Acknowledgement a
    = Yes a
    | No


targetSelectedOptions : Json.Decoder (List String)
targetSelectedOptions =
    Json.at [ "target", "selectedOptions" ] <|
        JsonEx.collection <|
            Json.at [ "value" ] <|
                Json.string


errorObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Error vars
errorObject =
    GQLBuilder.object Error
        |> GQLBuilder.with (GQLBuilder.field "message" [] GQLBuilder.string)


errorsField : GQLBuilder.SelectionSpec GQLBuilder.Field (Maybe (List Error)) vars
errorsField =
    GQLBuilder.field "errors"
        []
        (GQLBuilder.nullable
            (GQLBuilder.list errorObject)
        )


flattenErrors : Maybe (List Error) -> List String
flattenErrors =
    maybeToList >> List.concat >> List.map .message


selectItemsInList : List (Option a) -> List (Option { b | id : a }) -> List (Option { b | id : a })
selectItemsInList selectedItems itemList =
    List.foldl
        (\selectedItem acc ->
            selectItemInList selectedItem acc
        )
        itemList
        selectedItems


selectItemInList : Option a -> List (Option { b | id : a }) -> List (Option { b | id : a })
selectItemInList selectedItem itemList =
    List.map
        (\item ->
            case ( item, selectedItem ) of
                ( Selected innerItem, Unselected newItemId ) ->
                    if innerItem.id == newItemId then
                        Unselected innerItem

                    else
                        Selected innerItem

                ( Unselected innerItem, Selected newItemId ) ->
                    if innerItem.id == newItemId then
                        Selected innerItem

                    else
                        Unselected innerItem

                _ ->
                    item
        )
        itemList
