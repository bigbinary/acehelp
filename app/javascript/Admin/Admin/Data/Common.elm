module Admin.Data.Common exposing
    ( Error
    , Option(..)
    , Value
    , errorObject
    , errorsField
    , flattenErrors
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
