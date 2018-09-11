module Admin.Data.Common exposing (Option(..), Value, targetSelectedOptions)

import Json.Decode as Json
import Json.Decode.Extra as JsonEx
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


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
