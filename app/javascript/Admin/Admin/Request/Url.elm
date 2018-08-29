module Admin.Request.Url exposing (..)

import Admin.Request.Helper exposing (..)
import Admin.Data.Url exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestUrls : Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List UrlData)))
requestUrls =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request {} requestUrlsQuery
            )
        )


createUrl : CreateUrlInput -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe UrlData))
createUrl createUrlInput =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request createUrlInput createUrlMutation
            )
        )


deleteUrl : UrlId -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error UrlId)
deleteUrl urlId =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request { id = urlId } deleteUrlMutation
            )
        )


updateUrl : UrlData -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe UrlData))
updateUrl urlData =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request urlData updateUrlMutation
            )
        )


requestUrlById : UrlId -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe UrlData))
requestUrlById urlId =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request { id = urlId } urlByIdQuery
            )
        )
