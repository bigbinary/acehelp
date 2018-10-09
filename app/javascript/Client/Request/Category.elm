module Request.Category exposing (requestAllCategories)

import Data.Category exposing (Category, allCategoriesQuery, suggestedCategoriesQuery)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Reader exposing (Reader)
import Request.Helpers exposing (..)
import Task exposing (Task)


requestAllCategories : Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Category))
requestAllCategories =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendQuery (requestOptions env apiKey) <|
                GQLBuilder.request {} allCategoriesQuery
        )


requestSuggestedCategories : Context -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Category))
requestSuggestedCategories context =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendQuery (requestOptions env apiKey) <|
                GQLBuilder.request { url = contextToMaybe context } suggestedCategoriesQuery
        )
