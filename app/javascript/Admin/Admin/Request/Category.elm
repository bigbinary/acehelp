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


requestUpdateCategory : UpdateCategoryInputs -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Category)
requestUpdateCategory categoryInputs =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request
                    categoryInputs
                    udpateCategoryMutation
        )


deleteCategory : CategoryId -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error CategoryId)
deleteCategory categoryId =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request
                    { id = categoryId }
                    deleteCategoryMutation
        )


requestCreateCategory : CreateCategoryInputs -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Category)
requestCreateCategory categoryInputs =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request
                    categoryInputs
                    createCategoryMutation
        )
