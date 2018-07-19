module Request.CategoryRequest exposing (..)

import Data.CategoryData exposing (..)
import Request.RequestHelper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


categoryListUrl : NodeEnv -> Url
categoryListUrl env =
    (baseUrl env) ++ "/api/v1/all"


requestCategories : Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Category))
requestCategories =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.sendQuery (graphqlUrl env) <|
                GQLBuilder.request {} categoriesQuery
        )
