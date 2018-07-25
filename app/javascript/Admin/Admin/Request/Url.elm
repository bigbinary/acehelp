module Admin.Request.Url exposing (..)

import Admin.Request.Helper exposing (..)
import Admin.Data.Url exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


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
