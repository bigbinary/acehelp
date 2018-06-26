module Request.OrganizationRequest exposing (..)

import Http
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Request.RequestHelper exposing (..)
import Data.Organization as AD exposing (..)


organizationUrl : NodeEnv -> OrganizationId -> Url
organizationUrl env organizationId =
    (baseUrl env) ++ "/api/v1/organization/" ++ toString(organizationId) ++ "/data"


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
