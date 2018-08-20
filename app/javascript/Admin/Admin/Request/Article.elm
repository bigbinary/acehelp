module Admin.Request.Article exposing (..)

import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Article exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestArticlesByUrl : String -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (List ArticleSummary))
requestArticlesByUrl url =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request { url = url } articlesByUrlQuery
        )


requestCreateArticle : CreateArticleInputs -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error Article)
requestCreateArticle articleInputs =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                (GQLBuilder.request
                    { title = articleInputs.title
                    , desc = articleInputs.desc
                    , categoryIds = articleInputs.categoryIds
                    }
                    createArticleMutation
                )
        )


requestUpdateArticle : UpdateArticleInputs -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error Article)
requestUpdateArticle articleInputs =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
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


requestArticleById : ArticleId -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error Article)
requestArticleById articleId =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                (GQLBuilder.request
                    { id = articleId }
                    articleByIdQuery
                )
        )


requestAllArticles : Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error (List ArticleSummary))
requestAllArticles =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request {} allArticlesQuery
        )


requestDeleteArticle : ArticleId -> Reader ( NodeEnv, ApiKey, AppUrl ) (Task GQLClient.Error ArticleId)
requestDeleteArticle articleId =
    Reader.Reader
        (\( nodeEnv, apiKey, appUrl ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey appUrl) <|
                GQLBuilder.request { id = articleId } deleteArticleMutation
            )
        )
