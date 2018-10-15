module Request.Category exposing (requestAllCategories)

import Data.Category exposing (Category, allCategoriesQuery)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Reader exposing (Reader)
import Request.Helpers exposing (..)
import Task exposing (Task)


requestAllCategories : Reader ( AppUrl, ApiKey ) (Task GQLClient.Error (List Category))
requestAllCategories =
    Reader.Reader
        (\( appUrl, apiKey ) ->
            GQLClient.customSendQuery (requestOptions appUrl apiKey) <|
                GQLBuilder.request {} allCategoriesQuery
        )
