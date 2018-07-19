module Request.ArticleRequest exposing (..)

import Http
import Json.Decode as JsonDecoder exposing (field)
import Json.Encode as JsonEncoder
import Request.RequestHelper exposing (..)
import Data.ArticleData exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Request.Builder as GQLBuilder


articleListUrl : NodeEnv -> Url
articleListUrl env =
    (baseUrl env) ++ "/article"


articleCreateUrl : NodeEnv -> Url
articleCreateUrl env =
    (baseUrl env) ++ "/article"


requestArticles : NodeEnv -> Url -> ApiKey -> Http.Request ArticleListResponse
requestArticles env orgUrl apiKey =
    let
        requestData =
            { method = "GET"
            , url = articleListUrl env
            , params =
                [ ( "url", orgUrl )
                ]
            , body = Http.emptyBody
            , nodeEnv = env
            , organizationApiKey = apiKey
            }
    in
        httpRequest requestData articles


requestArticlesQuery : GQLBuilder.Document GQLBuilder.Query (List ArticleSummary) vars
requestArticlesQuery =
    GQLBuilder.queryDocument
        (GQLBuilder.extract
            (GQLBuilder.field "article"
                []
                (GQLBuilder.list
                    (GQLBuilder.object ArticleSummary
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "title" [] GQLBuilder.string)
                    )
                )
            )
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


createRequestMutation : GQLBuilder.Document GQLBuilder.Mutation Article CreateArticleInputs
createRequestMutation =
    let
        titleVar =
            Var.required "title" .title Var.string

        descVar =
            Var.required "desc" .desc Var.string

        categoryIdVar =
            Var.required "category_id" .category_id Var.int
    in
        GQLBuilder.mutationDocument <|
            GQLBuilder.extract
                (GQLBuilder.field "article"
                    [ ( "title", Arg.variable titleVar )
                    , ( "desc", Arg.variable descVar )
                    , ( "category_id", Arg.variable categoryIdVar )
                    ]
                    (GQLBuilder.object Article
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "title" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "desc" [] GQLBuilder.string)
                    )
                )
