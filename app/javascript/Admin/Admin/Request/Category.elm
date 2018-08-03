module Admin.Request.Category exposing (..)

import Admin.Data.Category exposing (..)
import Admin.Request.Helper exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Reader exposing (Reader)
import Task exposing (Task)


requestCategories : Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List Category))
requestCategories =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request {} categoriesQuery
        )


requestCategoryById : CategoryId -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Category)
requestCategoryById categoryId =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendQuery (requestOptions env apiKey) <|
                GQLBuilder.request
                    { id = categoryId }
                    categoryByIdQuery
        )


requestUpdateCategory : Reader ( NodeEnv, ApiKey, UpdateCategoryInputs ) (Task GQLClient.Error Category)
requestUpdateCategory =
    Reader.Reader
        (\( nodeEnv, apiKey, categoryInputs ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request
                    categoryInputs
                    udpateCategoryMutation
        )
