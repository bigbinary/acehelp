module Data.Article exposing (..)

import Data.Common exposing (..)
import Json.Decode exposing (int, string, float, nullable, list, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias ArticleId =
    String


type alias ArticleListResponse =
    { articles : List ArticleSummary }


type alias ArticleResponse =
    { article : Article }


type alias Article =
    { id : ArticleId
    , title : String
    , content : String
    }


type alias ArticleSummary =
    { id : ArticleId
    , title : String
    }



-- QUERIES


articleQuery : GQLBuilder.Document GQLBuilder.Query Article { vars | articleId : ArticleId }
articleQuery =
    let
        articleIdVar =
            Var.required "articleId" .articleId Var.string
    in
        GQLBuilder.queryDocument <|
            GQLBuilder.extract <|
                GQLBuilder.field "article"
                    [ ( "id", Arg.variable articleIdVar ) ]
                    (GQLBuilder.object Article
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "title" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "desc" [] GQLBuilder.string)
                    )


articleSummaryField : GQLBuilder.SelectionSpec GQLBuilder.Field (List ArticleSummary) vars
articleSummaryField =
    GQLBuilder.field "articles"
        []
        (GQLBuilder.list
            (GQLBuilder.object ArticleSummary
                |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                |> GQLBuilder.with (GQLBuilder.field "title" [] GQLBuilder.string)
            )
        )


articlesQuery : GQLBuilder.Document GQLBuilder.Query (List ArticleSummary) vars
articlesQuery =
    GQLBuilder.queryDocument <|
        GQLBuilder.extract articleSummaryField



-- MUTATIONS


voteMutation : String -> GQLBuilder.Document GQLBuilder.Mutation ArticleSummary { vars | articleId : ArticleId }
voteMutation voteType =
    let
        articleIdVar =
            Var.required "articleId" (toString << .articleId) Var.id

        article =
            GQLBuilder.extract <|
                GQLBuilder.field "article"
                    []
                    (GQLBuilder.object ArticleSummary
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "title" [] GQLBuilder.string)
                    )

        queryRoot =
            GQLBuilder.extract
                (GQLBuilder.field voteType
                    [ ( "input", Arg.object [ ( "id", Arg.variable articleIdVar ) ] ) ]
                    article
                )
    in
        GQLBuilder.mutationDocument queryRoot


upvoteMutation : GQLBuilder.Document GQLBuilder.Mutation ArticleSummary { vars | articleId : ArticleId }
upvoteMutation =
    voteMutation "upvoteArticle"


downvoteMutation : GQLBuilder.Document GQLBuilder.Mutation ArticleSummary { vars | articleId : ArticleId }
downvoteMutation =
    voteMutation "downvoteArticle"



-- DECODERS


decodeArticles : Decoder ArticleListResponse
decodeArticles =
    decode ArticleListResponse
        |> required "articles" (list decodeArticleSummary)


decodeArticleSummary : Decoder ArticleSummary
decodeArticleSummary =
    decode ArticleSummary
        |> required "id" string
        |> required "title" string


decodeArticle : Decoder Article
decodeArticle =
    decode Article
        |> required "id" string
        |> required "title" string
        |> required "desc" string


decodeArticleResponse : Decoder ArticleResponse
decodeArticleResponse =
    decode ArticleResponse
        |> required "article" decodeArticle
