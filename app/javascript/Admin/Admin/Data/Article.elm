module Admin.Data.Article exposing (..)

import Json.Decode exposing (..)
import Json.Decode.Pipeline as Pipeline exposing (decode, required)
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Request.Builder as GQLBuilder
import Admin.Data.Category exposing (CategoryId)
import Admin.Data.Url exposing (UrlId, UrlData, urlExtractor)


type alias ArticleId =
    String


type alias Article =
    { id : ArticleId
    , title : String
    , desc : String
    , categoryId : CategoryId
    , urls : List UrlData
    }


type alias CreateArticleInputs =
    { title : String
    , desc : String
    , categoryId : String
    }


type alias ArticleSummary =
    { id : ArticleId
    , title : String
    }


type alias ArticleListResponse =
    { articles : List Article
    }


decodeArticleSummary : Decoder ArticleSummary
decodeArticleSummary =
    decode ArticleSummary
        |> required "id" string
        |> required "title" string


requestArticlesQuery : GQLBuilder.Document GQLBuilder.Query (List ArticleSummary) { vars | url : String }
requestArticlesQuery =
    let
        urlVar =
            Var.required "url" .url Var.string
    in
        GQLBuilder.queryDocument
            (GQLBuilder.extract
                (GQLBuilder.field "articles"
                    [ ( "url", Arg.variable urlVar ) ]
                    (GQLBuilder.list
                        (GQLBuilder.object ArticleSummary
                            |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                            |> GQLBuilder.with (GQLBuilder.field "title" [] GQLBuilder.string)
                        )
                    )
                )
            )


requestArticlByIdQuery : GQLBuilder.Document GQLBuilder.Query (List Article) { vars | id : String }
requestArticlByIdQuery =
    let
        idVar =
            Var.required "id" .id Var.string
    in
        GQLBuilder.queryDocument
            (GQLBuilder.extract
                (GQLBuilder.field "article"
                    [ ( "id", Arg.variable idVar ) ]
                    (GQLBuilder.list
                        articleObject
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
            Var.required "category_id" .categoryId Var.string
    in
        GQLBuilder.mutationDocument <|
            GQLBuilder.extract
                (GQLBuilder.field "addArticle"
                    [ ( "input"
                      , Arg.object
                            [ ( "title", Arg.variable titleVar )
                            , ( "desc", Arg.variable descVar )
                            , ( "category_id", Arg.variable categoryIdVar )
                            ]
                      )
                    ]
                    (GQLBuilder.extract <|
                        GQLBuilder.field "article"
                            []
                            articleObject
                    )
                )


articleObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Article vars
articleObject =
    GQLBuilder.object Article
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "title" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "desc" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "categoryId" [] GQLBuilder.string)
        |> GQLBuilder.with
            (GQLBuilder.field "urls"
                []
                (GQLBuilder.list
                    urlExtractor
                )
            )
