module Admin.Request.Category exposing (..)

import Admin.Data.Category exposing (..)
import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestCategories : Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Category))
requestCategories =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request {} categoriesQuery
        )
