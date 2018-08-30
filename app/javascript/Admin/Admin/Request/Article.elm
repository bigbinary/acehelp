module Admin.Request.Article exposing (..)

import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Article exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Admin.Data.Status exposing (..)
import Admin.Data.Session exposing (..)


requestArticlesByUrl : String -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List ArticleSummary)))
requestArticlesByUrl url =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request { url = url } articlesByUrlQuery
        )


requestCreateArticle : CreateArticleInputs -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Article))
requestCreateArticle articleInputs =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                (GQLBuilder.request
                    { title = articleInputs.title
                    , desc = articleInputs.desc
                    , categoryIds = articleInputs.categoryIds
                    }
                    createArticleMutation
                )
        )


requestUpdateArticle : UpdateArticleInputs -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Article))
requestUpdateArticle articleInputs =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                (GQLBuilder.request
                    { id = articleInputs.id
                    , title = articleInputs.title
                    , desc = articleInputs.desc
                    , categoryId = articleInputs.categoryId
                    , urlId = articleInputs.urlId
                    }
                    updateArticleMutation
                )
        )


requestArticleById : ArticleId -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Article))
requestArticleById articleId =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                (GQLBuilder.request
                    { id = articleId }
                    articleByIdQuery
                )
        )


requestAllArticles : Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe (List ArticleSummary)))
requestAllArticles =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request {} allArticlesQuery
        )


requestDeleteArticle : ArticleId -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe ArticleId))
requestDeleteArticle articleId =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request { id = articleId } deleteArticleMutation
            )
        )


requestUpdateArticleStatus : ArticleId -> AvailabilitySatus -> Reader ( Token, NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (Maybe Article))
requestUpdateArticleStatus articleId articleStatus =
    Reader.Reader
        (\( tokens, nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptionsWithToken (Just tokens) nodeEnv apiKey appUrl) <|
                GQLBuilder.request { id = articleId, status = availablityStatusIso.get articleStatus } articleStatusMutation
            )
        )
