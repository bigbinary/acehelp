module Data.Article exposing (Article, ArticleId, ArticleListResponse, ArticleResponse, ArticleSummary, addFeedbackMutation, articleQuery, articleSummaryField, articlesQuery, decodeArticle, decodeArticleResponse, decodeArticleSummary, decodeArticles, downvoteMutation, searchArticlesQuery, suggestedArticledQuery, upvoteMutation, voteMutation)

import Data.Common exposing (..)
import Data.ContactUs exposing (FeedbackForm)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Json.Decode as Decode exposing (Decoder, float, int, list, nullable, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, optional, required)
import Request.Helpers exposing (..)


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


searchArticlesQuery : GQLBuilder.Document GQLBuilder.Query (List ArticleSummary) { vars | searchString : String }
searchArticlesQuery =
    let
        searchStringVar =
            Var.required "searchString" .searchString Var.string
    in
    GQLBuilder.queryDocument <|
        GQLBuilder.extract <|
            GQLBuilder.field "articles"
                [ ( "search_string", Arg.variable searchStringVar ) ]
                (GQLBuilder.list
                    (GQLBuilder.object ArticleSummary
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "title" [] GQLBuilder.string)
                    )
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


suggestedArticledQuery : GQLBuilder.Document GQLBuilder.Query (List ArticleSummary) { vars | url : Maybe String, status : Maybe String }
suggestedArticledQuery =
    let
        urlVar =
            Var.optional "url" .url Var.string ""

        statusVar =
            Var.optional "status" .status Var.string ""
    in
    GQLBuilder.queryDocument <|
        GQLBuilder.extract <|
            GQLBuilder.field "articles"
                [ ( "url", Arg.variable urlVar )
                , ( "status", Arg.variable statusVar )
                ]
                (GQLBuilder.list
                    (GQLBuilder.object ArticleSummary
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "title" [] GQLBuilder.string)
                    )
                )



-- MUTATIONS


voteMutation : String -> GQLBuilder.Document GQLBuilder.Mutation ArticleSummary { vars | articleId : ArticleId }
voteMutation voteType =
    let
        articleIdVar =
            Var.required "articleId" .articleId Var.id

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


addFeedbackMutation : GQLBuilder.Document GQLBuilder.Mutation (Maybe (List GQLError)) FeedbackForm
addFeedbackMutation =
    let
        guestNameVar =
            Var.required "name" .name Var.string

        guestMessageVar =
            Var.required "message" .comment Var.string

        articleIdVar =
            Var.required "article_id" .article_id Var.string
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract <|
            GQLBuilder.field "addFeedback"
                [ ( "input"
                  , Arg.object
                        [ ( "name", Arg.variable guestNameVar )
                        , ( "message", Arg.variable guestMessageVar )
                        , ( "article_id", Arg.variable articleIdVar )
                        ]
                  )
                ]
                errorsExtractor


upvoteMutation : GQLBuilder.Document GQLBuilder.Mutation ArticleSummary { vars | articleId : ArticleId }
upvoteMutation =
    voteMutation "upvoteArticle"


downvoteMutation : GQLBuilder.Document GQLBuilder.Mutation ArticleSummary { vars | articleId : ArticleId }
downvoteMutation =
    voteMutation "downvoteArticle"



-- DECODERS


decodeArticles : Decoder ArticleListResponse
decodeArticles =
    succeed ArticleListResponse
        |> required "articles" (list decodeArticleSummary)


decodeArticleSummary : Decoder ArticleSummary
decodeArticleSummary =
    succeed ArticleSummary
        |> required "id" string
        |> required "title" string


decodeArticle : Decoder Article
decodeArticle =
    succeed Article
        |> required "id" string
        |> required "title" string
        |> required "desc" string


decodeArticleResponse : Decoder ArticleResponse
decodeArticleResponse =
    succeed ArticleResponse
        |> required "article" decodeArticle
