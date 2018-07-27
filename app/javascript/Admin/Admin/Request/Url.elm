module Admin.Request.Url exposing (..)

import Admin.Request.Helper exposing (..)
import Admin.Data.Url exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestUrls : Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List UrlData))
requestUrls =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            (GQLClient.customSendQuery (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request {} requestUrlsQuery
            )
        )


createUrl : Reader ( NodeEnv, ApiKey, CreateUrlInput ) (Task GQLClient.Error UrlData)
createUrl =
    Reader.Reader
        (\( nodeEnv, apiKey, createUrlInput ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request createUrlInput createUrlMutation
            )
        )


deleteUrl : Reader ( NodeEnv, ApiKey, UrlIdInput ) (Task GQLClient.Error UrlIdInput)
deleteUrl =
    Reader.Reader
        (\( nodeEnv, apiKey, urlId ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request urlId deleteUrlMutation
            )
        )
