module Request.Organization exposing (..)

import Task exposing (Task)
import Reader exposing (Reader)
import Request.Helpers exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Data.Organization exposing (..)


requestOrganizations : ApiKey -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Organization)
requestOrganizations apiKey =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendQuery (requestOptions env apiKey) <|
                GQLBuilder.request { apiKey = apiKey } organizationQuery
        )
