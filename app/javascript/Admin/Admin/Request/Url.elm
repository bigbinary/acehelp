module Admin.Request.Url exposing (..)

import Admin.Request.Helper exposing (..)
import Admin.Data.Url exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Admin.Data.Session exposing (Token)


requestUrls : Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List UrlData)))
requestUrls =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendQuery (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request {} requestUrlsQuery
            )
        )


createUrl : CreateUrlInput -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe UrlData))
createUrl createUrlInput =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request createUrlInput createUrlMutation
            )
        )


deleteUrl : UrlId -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error UrlId)
deleteUrl urlId =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request { id = urlId } deleteUrlMutation
            )
        )


updateUrl : UrlData -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe UrlData))
updateUrl urlData =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request urlData updateUrlMutation
            )
        )


requestUrlById : UrlId -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe UrlData))
requestUrlById urlId =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendQuery (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request { id = urlId } urlByIdQuery
            )
        )
