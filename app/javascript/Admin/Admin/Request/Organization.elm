module Admin.Request.Organization exposing (requestAllOrganizations, requestCreateOrganization)

import Admin.Data.Organization exposing (..)
import Admin.Request.Helper exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Http
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Reader exposing (Reader)
import Task exposing (Task)


requestCreateOrganization :
    OrganizationData
    -> Reader ( NodeEnv, AppUrl ) (Task GQLClient.Error OrganizationResponse)
requestCreateOrganization orgInputs =
    Reader.Reader
        (\( nodeEnv, appUrl ) ->
            GQLClient.sendMutation (graphqlUrl nodeEnv appUrl) <|
                GQLBuilder.request
                    { name = orgInputs.name
                    , email = orgInputs.email
                    , userId = orgInputs.userId
                    }
                    createOrganizationMutation
        )


requestAllOrganizations : Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List Organization)))
requestAllOrganizations =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request {} fetchOrganizationsQuery
        )
