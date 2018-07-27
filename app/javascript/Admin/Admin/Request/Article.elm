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


requestCreateArticle : Reader ( NodeEnv, ApiKey, CreateArticleInputs ) (Task GQLClient.Error Article)
requestCreateArticle =
    Reader.Reader
        (\( nodeEnv, apiKey, articleInputs ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                (GQLBuilder.request
                    { title = articleInputs.title
                    , desc = articleInputs.desc
                    , categoryId = articleInputs.categoryId
                    }
                    createArticleMutation
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
