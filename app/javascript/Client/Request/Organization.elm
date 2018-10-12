module Request.Organization exposing (requestOrganizations)

import Data.Organization exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Reader exposing (Reader)
import Request.Helpers exposing (..)
import Task exposing (Task)


requestOrganizations : Reader ( AppUrl, ApiKey ) (Task GQLClient.Error Organization)
requestOrganizations =
    Reader.Reader
        (\( appUrl, apiKey ) ->
            GQLClient.customSendQuery (requestOptions appUrl apiKey) <|
                GQLBuilder.request {} organizationQuery
        )
