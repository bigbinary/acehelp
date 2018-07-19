module Request.ArticleRequest exposing (..)

import Http
import Json.Decode as JsonDecoder exposing (field)
import Json.Encode as JsonEncoder
import Request.RequestHelper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Data.ArticleData exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


articleListUrl : NodeEnv -> Url
articleListUrl env =
    (baseUrl env) ++ "/article"


articleCreateUrl : NodeEnv -> Url
articleCreateUrl env =
    (baseUrl env) ++ "/article"


requestArticles : Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error (List ArticleSummary))
requestArticles =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            GQLClient.sendQuery (graphqlUrl nodeEnv) <|
                GQLBuilder.request {} requestArticlesQuery
        )


requestCreateArticle : NodeEnv -> ApiKey -> JsonEncoder.Value -> Http.Request String
requestCreateArticle env apiKey body =
    let
        requestData =
            { url = articleCreateUrl env
            , method = "POST"
            , params = []
            , body = Http.jsonBody <| body
            , nodeEnv = env
            , organizationApiKey = apiKey
            }

        decoder =
            field "_id" JsonDecoder.string
    in
        httpRequest requestData decoder
