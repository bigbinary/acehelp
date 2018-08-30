module Admin.Request.Organization exposing (..)

import Http
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Admin.Request.Helper exposing (..)
import Admin.Data.Organization exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Admin.Data.Session exposing (Token)


requestCreateOrganization : OrganizationData -> Reader ( Token, NodeEnv, AppUrl ) (Task GQLClient.Error Organization)
requestCreateOrganization orgInputs =
    Reader.Reader
        (\( token, nodeEnv, appUrl ) ->
            GQLClient.customSendMutation (requestOptionsWithToken (Just token) nodeEnv "" appUrl) <|
                (GQLBuilder.request
                    { name = orgInputs.name
                    , email = orgInputs.email
                    , userId = orgInputs.userId
                    }
                    createOrganizationMutation
                )
        )
