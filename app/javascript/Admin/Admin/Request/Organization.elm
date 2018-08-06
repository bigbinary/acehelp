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


organizationUrl : NodeEnv -> OrganizationId -> Url
organizationUrl env organizationId =
    (baseUrl env) ++ "/api/v1/organization/" ++ toString (organizationId) ++ "/data"


requestOrganization : NodeEnv -> ApiKey -> OrganizationId -> Http.Request OrganizationResponse
requestOrganization env apiKey organizationId =
    let
        url =
            (organizationUrl env organizationId)

        headers =
            List.concat
                [ defaultRequestHeaders
                , [ (Http.header "api-key" apiKey) ]
                ]

        decoder =
            field "_id" JD.string
    in
        Http.request
            { method = "GET"
            , headers = headers
            , url = url
            , body = Http.emptyBody
            , expect = Http.expectJson organization
            , timeout = Nothing
            , withCredentials = False
            }


requestCreateOrganization : OrganizationData -> Reader NodeEnv (Task GQLClient.Error Organization)
requestCreateOrganization orgInputs =
    Reader.Reader
        (\env ->
            GQLClient.sendMutation (graphqlUrl env) <|
                (GQLBuilder.request
                    { name = orgInputs.name
                    , email = orgInputs.email
                    , userId = orgInputs.userId
                    }
                    createOrganizationMutation
                )
        )
