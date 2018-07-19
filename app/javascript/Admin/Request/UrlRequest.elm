module Request.UrlRequest exposing (..)

import Http
import Json.Decode as JsonDecoder exposing (field)
import Json.Encode as JsonEncoder
import Request.RequestHelper exposing (..)
import Data.UrlData exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


urlList : NodeEnv -> Url
urlList nodeEnv =
    (baseUrl nodeEnv) ++ "/url"


urlCreate : NodeEnv -> Url
urlCreate nodeEnv =
    (baseUrl nodeEnv) ++ "/url"


requestUrls : Reader NodeEnv (Task GQLClient.Error (List UrlData))
requestUrls =
    Reader.Reader
        (\nodeEnv ->
            (GQLClient.sendQuery (graphqlUrl nodeEnv) <|
                GQLBuilder.request {} requestUrlsQuery
            )
        )


createUrl : NodeEnv -> ApiKey -> JsonEncoder.Value -> Http.Request String
createUrl nodeEnv apiKey body =
    let
        requestData =
            { method = "POST"
            , url = urlCreate nodeEnv
            , params = []
            , body = Http.jsonBody <| body
            , nodeEnv = nodeEnv
            , organizationApiKey = apiKey
            }

        decoder =
            JsonDecoder.field "_id" JsonDecoder.string
    in
        httpRequest requestData decoder
