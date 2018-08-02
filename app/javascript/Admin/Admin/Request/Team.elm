module Admin.Request.Team exposing (..)

import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Team exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestTeam : Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List TeamMember))
requestTeam =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            (GQLClient.customSendQuery (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request {} requestTeamQuery
            )
        )
