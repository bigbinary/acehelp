module Admin.Request.Category exposing (..)

import Admin.Data.Category exposing (..)
import Admin.Request.Helper exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Status exposing (..)
import Admin.Data.Session exposing (Token)


requestCategories : Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List Category)))
requestCategories =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request {} categoriesQuery
        )


requestCategoryById : CategoryId -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Category))
requestCategoryById categoryId =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request
                    { id = categoryId }
                    categoryByIdQuery
        )


requestUpdateCategory : UpdateCategoryInputs -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Category))
requestUpdateCategory categoryInputs =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request
                    categoryInputs
                    udpateCategoryMutation
        )


deleteCategory : CategoryId -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe CategoryId))
deleteCategory categoryId =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request
                    { id = categoryId }
                    deleteCategoryMutation
        )


requestCreateCategory : CreateCategoryInputs -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Category))
requestCreateCategory categoryInputs =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request
                    categoryInputs
                    createCategoryMutation
        )


requestUpdateCategoryStatus : CategoryId -> String -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List Category)))
requestUpdateCategoryStatus categoryId categoryStatus =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request { id = categoryId, status = categoryStatus } updateCategoryStatusMutation
            )
        )
