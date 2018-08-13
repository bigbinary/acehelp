module Admin.Request.Article exposing (..)

import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Article exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestArticlesByUrl : String -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List ArticleSummary))
requestArticlesByUrl url =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request { url = url } articlesByUrlQuery
        )


requestCreateArticle : CreateArticleInputs -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Article)
requestCreateArticle articleInputs =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                (GQLBuilder.request
                    { title = articleInputs.title
                    , desc = articleInputs.desc
                    , categoryId = articleInputs.categoryId
                    }
                    createArticleMutation
                )
        )


requestUpdateArticle : UpdateArticleInputs -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Article)
requestUpdateArticle articleInputs =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                (GQLBuilder.request
                    { id = articleInputs.id
                    , title = articleInputs.title
                    , desc = articleInputs.desc
                    , categoryId = articleInputs.categoryId
                    }
                    updateArticleMutation
                )
        )


requestArticleById : ArticleId -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error Article)
requestArticleById articleId =
    Reader.Reader
        (\( env, apiKey ) ->
            GQLClient.customSendQuery (requestOptions env apiKey) <|
                (GQLBuilder.request
                    { id = articleId }
                    articleByIdQuery
                )
        )


requestAllArticles : Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List ArticleSummary))
requestAllArticles =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            GQLClient.customSendQuery (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request {} allArticlesQuery
        )


requestDeleteArticle : Reader ( NodeEnv, ApiKey, ArticleIdInput ) (Task GQLClient.Error ArticleId)
requestDeleteArticle =
    Reader.Reader
        (\( nodeEnv, apiKey, articleId ) ->
            (GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                GQLBuilder.request articleId deleteArticleMutation
            )
        )
