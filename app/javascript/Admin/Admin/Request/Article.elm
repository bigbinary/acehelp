module Admin.Request.Article exposing (..)

import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Article exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestArticles : String -> Reader NodeEnv (Task GQLClient.Error (List ArticleSummary))
requestArticles url =
    Reader.Reader
        (\nodeEnv ->
            GQLClient.sendQuery (graphqlUrl nodeEnv) <|
                GQLBuilder.request { url = url } requestArticlesQuery
        )


requestCreateArticle : CreateArticleInputs -> Reader NodeEnv (Task GQLClient.Error Article)
requestCreateArticle articleInputs =
    Reader.Reader
        (\env ->
            GQLClient.sendMutation (graphqlUrl env) <|
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
            GQLClient.sendQuery (graphqlUrl env) <|
                (GQLBuilder.request
                    { id = articleId }
                    articleByIdQuery
                )
        )
