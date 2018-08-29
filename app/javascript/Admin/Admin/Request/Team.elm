module Admin.Request.Team exposing (..)

import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Team exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestTeam : Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List Team)))
requestTeam =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request {} requestTeamQuery
            )
        )


createTeamMember : TeamMember -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Team))
createTeamMember createTeamMemberInput =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request createTeamMemberInput createTeamMemberMutation
            )
        )


removeTeamMember : String -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List Team)))
removeTeamMember userEmail =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request { email = userEmail } removeUserFromOrganization
            )
        )
