module Admin.Request.Team exposing (..)

import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Team exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestTeam : Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Team))
requestTeam =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            (GQLClient.customSendQuery (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request {} requestTeamQuery
            )
        )


createTeamMember : TeamMember -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Team)
createTeamMember createTeamMemberInput =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request createTeamMemberInput createTeamMemberMutation
            )
        )


removeTeamMember : String -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Team))
removeTeamMember userEmail =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request { email = userEmail } removeUserFromOrganization
            )
        )
