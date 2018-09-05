module Admin.Request.Category exposing (..)

import Admin.Data.Category exposing (..)
import Admin.Request.Helper exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Status exposing (..)


requestCategories : Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List Category)))
requestCategories =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request {} categoriesQuery
        )


requestCategoryById : CategoryId -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Category))
requestCategoryById categoryId =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request
                    { id = categoryId }
                    categoryByIdQuery
        )


requestUpdateCategory : UpdateCategoryInputs -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Category))
requestUpdateCategory categoryInputs =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request
                    categoryInputs
                    udpateCategoryMutation
        )


deleteCategory : CategoryId -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe CategoryId))
deleteCategory categoryId =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request
                    { id = categoryId }
                    deleteCategoryMutation
        )


requestCreateCategory : CreateCategoryInputs -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Category))
requestCreateCategory categoryInputs =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request
                    categoryInputs
                    createCategoryMutation
        )


requestUpdateCategoryStatus : CategoryId -> String -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List Category)))
requestUpdateCategoryStatus categoryId categoryStatus =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request { id = categoryId, status = reverseCurrentAvailabilityStatus (categoryStatus) } updateCategoryStatusMutation
            )
        )
