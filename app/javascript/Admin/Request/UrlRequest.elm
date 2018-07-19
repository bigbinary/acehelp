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


createUrl : Reader ( NodeEnv, CreateUrlInput ) (Task GQLClient.Error UrlData)
createUrl =
    Reader.Reader
        (\( nodeEnv, createUrlInput ) ->
            (GQLClient.sendMutation (graphqlUrl nodeEnv) <|
                GQLBuilder.request createUrlInput createUrlMutation
            )
        )
