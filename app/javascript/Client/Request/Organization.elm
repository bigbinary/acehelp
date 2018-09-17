module Request.Organization exposing (requestOrganizations)

import Data.Organization exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Reader exposing (Reader)
import Request.Helpers exposing (..)
import Task exposing (Task)


requestOrganizations : Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Organization)
requestOrganizations =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendQuery (requestOptions env apiKey) <|
                GQLBuilder.request {} organizationQuery
        )
