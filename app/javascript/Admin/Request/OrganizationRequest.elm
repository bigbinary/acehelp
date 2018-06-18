module Request.OrganizationRequest exposing (..)

import Http
import Json.Decode as JD exposing (field)
import Json.Encode as JE
import Request.RequestHelper exposing (..)
import Data.OrganizationData as AD exposing (..)


organizationUrl : NodeEnv -> Url
organizationUrl env =
    (baseUrl env) ++ ""


requestOrganization : NodeEnv -> ApiKey -> Http.Request OrganizationResponse
requestOrganization env apiKey =
    let
        url =
            (organizationUrl env)

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
