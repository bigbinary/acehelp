module Data.Article exposing (..)

import Json.Decode exposing (int, string, float, nullable, list, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias ArticleId =
    Int


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



-- TODO: USE GRAPHQL
-- ENCODERS


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
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.int)
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
        |> required "id" int
        |> required "title" string


decodeArticle : Decoder Article
decodeArticle =
    decode Article
        |> required "id" int
        |> required "title" string
        |> required "desc" string


decodeArticleResponse : Decoder ArticleResponse
decodeArticleResponse =
    decode ArticleResponse
        |> required "article" decodeArticle
