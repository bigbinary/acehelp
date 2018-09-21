module Admin.Request exposing (requestAllArticles)

import Admin.Data exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Reader exposing (Reader)
import Task exposing (Task)


requestAllArticles : Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List Organization)))
requestAllArticles =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request {} fetchOrganizationsQuery
        )
