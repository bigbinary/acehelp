module Data.Common exposing (..)

import Request.Helpers exposing (..)
import Reader exposing (..)
import GraphQL.Request.Builder as GQLBuilder


type SectionCmd msg
    = Strict (Reader ( NodeEnv, ApiKey ) (Cmd msg))


type alias GQLError =
    { message : String }


type alias GQLErrors =
    { errors : List GQLError
    }


type Stuff a e
    = IsA a
    | None
    | Error e


sectionCmdToCmd : NodeEnv -> ApiKey -> (msg -> msg1) -> List (SectionCmd msg) -> Cmd msg1
sectionCmdToCmd nodeEnv apiKey mapMsg =
    Cmd.batch
        << List.map
            (\cmd ->
                case cmd of
                    Strict reader ->
                        Cmd.map mapMsg <|
                            Reader.run reader ( nodeEnv, apiKey )
            )


errorsExtractor : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType (Maybe (List GQLError)) vars
errorsExtractor =
    GQLBuilder.extract <|
        GQLBuilder.field "errors"
            []
            (GQLBuilder.nullable
                (GQLBuilder.list
                    (GQLBuilder.object GQLError
                        |> GQLBuilder.with
                            (GQLBuilder.field "message"
                                []
                                GQLBuilder.string
                            )
                    )
                )
            )
