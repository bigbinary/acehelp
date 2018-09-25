module Admin.Request exposing (requestAllOrganizations)

import Admin.Data exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Reader exposing (Reader)
import Task exposing (Task)


requestAllOrganizations : Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List Organization)))
requestAllOrganizations =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request {} fetchOrganizationsQuery
        )
