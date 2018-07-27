module Request.Category exposing (..)

import Task exposing (Task)
import Reader exposing (Reader)
import Data.Category exposing (Category, allCategoriesQuery)
import Request.Helpers exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestAllCategories : Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Category))
requestAllCategories =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendQuery (requestOptions env apiKey) <|
                GQLBuilder.request {} allCategoriesQuery
        )
