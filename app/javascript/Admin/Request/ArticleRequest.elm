module Request.ArticleRequest exposing (..)

import Request.RequestHelper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Data.ArticleData exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


requestArticles : String -> Reader NodeEnv (Task GQLClient.Error (List ArticleSummary))
requestArticles url =
    Reader.Reader
        (\nodeEnv ->
            GQLClient.sendQuery (graphqlUrl nodeEnv) <|
                GQLBuilder.request { url = url } requestArticlesQuery
        )


requestCreateArticle : Reader ( NodeEnv, CreateArticleInputs ) (Task GQLClient.Error Article)
requestCreateArticle =
    Reader.Reader
        (\( env, articleInputs ) ->
            GQLClient.sendMutation (graphqlUrl env) <|
                (GQLBuilder.request
                    { title = articleInputs.title
                    , desc = articleInputs.desc
                    , category_id = articleInputs.category_id
                    }
                    createArticleMutation
                )
        )
