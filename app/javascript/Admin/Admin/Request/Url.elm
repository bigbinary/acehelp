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


createUrl : CreateUrlInput -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error UrlData)
createUrl createUrlInput =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request createUrlInput createUrlMutation
            )
        )


deleteUrl : UrlId -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error UrlId)
deleteUrl urlId =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request { id = urlId } deleteUrlMutation
            )
        )


updateUrl : UrlData -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error UrlData)
updateUrl urlData =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request urlData updateUrlMutation
            )
        )


requestUrlById : UrlId -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error UrlData)
requestUrlById urlId =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            (GQLClient.customSendQuery (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request { id = urlId } urlByIdQuery
            )
        )
