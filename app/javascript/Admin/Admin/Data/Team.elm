module Admin.Data.Team exposing (..)

--import GraphQL.Request.Builder.Arg as Arg
--import GraphQL.Request.Builder.Variable as Var

import GraphQL.Request.Builder as GQLBuilder


type alias UserId =
    String


type alias TeamMember =
    { id : UserId
    , name : String
    , email : String
    }


requestTeamQuery : GQLBuilder.Document GQLBuilder.Query (List TeamMember) vars
requestTeamQuery =
    GQLBuilder.queryDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "users"
                []
                (GQLBuilder.list
                    teamMemberExtractor
                )
            )


teamMemberExtractor : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType TeamMember vars
teamMemberExtractor =
    (GQLBuilder.object TeamMember
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "email" [] GQLBuilder.string)
    )
