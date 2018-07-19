module Data.ArticleData exposing (..)

import Json.Decode exposing (..)
import Json.Decode.Pipeline as Pipeline exposing (decode, hardcoded, optional, required)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Request.Builder as GQLBuilder


type alias ArticleId =
    String


type alias Article =
    { id : ArticleId
    , title : String
    , desc : String
    }


type alias CreateArticleInputs =
    { title : String
    , desc : String
    , category_id : Int
    }


type alias ArticleSummary =
    { id : ArticleId
    , title : String
    }


type alias ArticleListResponse =
    { articles : List Article
    }


articles : Decoder ArticleListResponse
articles =
    decode ArticleListResponse
        |> required "articles" (list articlesDecoder)


articlesDecoder : Decoder Article
articlesDecoder =
    decode Article
        |> required "id" string
        |> required "title" string
        |> required "desc" string


decodeArticles : Decoder (List ArticleSummary)
decodeArticles =
    list decodeArticleSummary


decodeArticleSummary : Decoder ArticleSummary
decodeArticleSummary =
    decode ArticleSummary
        |> required "id" string
        |> required "title" string


requestArticlesQuery : GQLBuilder.Document GQLBuilder.Query (List ArticleSummary) vars
requestArticlesQuery =
    GQLBuilder.queryDocument
        (GQLBuilder.extract
            (GQLBuilder.field "articles"
                []
                (GQLBuilder.list
                    (GQLBuilder.object ArticleSummary
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "title" [] GQLBuilder.string)
                    )
                )
            )
        )


createArticleMutation : GQLBuilder.Document GQLBuilder.Mutation Article CreateArticleInputs
createArticleMutation =
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
