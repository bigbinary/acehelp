module Admin.Data.Article exposing (..)

import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Request.Builder as GQLBuilder
import Admin.Data.Category exposing (CategoryId, categoryObject, Category)
import Admin.Data.Url exposing (UrlId, UrlData, urlObject)


type alias ArticleId =
    String


type alias Article =
    { id : ArticleId
    , title : String
    , desc : String
    , status : String
    , categories : List Category
    , urls : List UrlData
    }


type alias CreateArticleInputs =
    { title : String
    , desc : String
    , categoryIds : Maybe (List CategoryId)
    }


type alias UpdateArticleInputs =
    { id : ArticleId
    , title : String
    , desc : String
    , categoryId : Maybe String
    , urlId : Maybe String
    }


type alias ArticleSummary =
    { id : ArticleId
    , title : String
    , status : String
    }


type alias ArticleListResponse =
    { articles : List Article
    }


articlesByUrlQuery : GQLBuilder.Document GQLBuilder.Query (Maybe (List ArticleSummary)) { vars | url : String }
articlesByUrlQuery =
    let
        urlVar =
            Var.required "url" .url Var.string
    in
        GQLBuilder.queryDocument
            (GQLBuilder.extract
                (GQLBuilder.field "articles"
                    [ ( "url", Arg.variable urlVar ) ]
                    (GQLBuilder.nullable
                        (GQLBuilder.list
                            articleSummaryObject
                        )
                    )
                )
            )


allArticlesQuery : GQLBuilder.Document GQLBuilder.Query (Maybe (List ArticleSummary)) {}
allArticlesQuery =
    GQLBuilder.queryDocument
        (GQLBuilder.extract
            (GQLBuilder.field "articles"
                []
                (GQLBuilder.nullable
                    (GQLBuilder.list
                        articleSummaryObject
                    )
                )
            )
        )


articleByIdQuery : GQLBuilder.Document GQLBuilder.Query (Maybe Article) { vars | id : ArticleId }
articleByIdQuery =
    let
        idVar =
            Var.required "id" .id Var.string
    in
        GQLBuilder.queryDocument
            (GQLBuilder.extract
                (GQLBuilder.field "article"
                    [ ( "id", Arg.variable idVar ) ]
                    (GQLBuilder.nullable articleObject)
                )
            )


createArticleMutation : GQLBuilder.Document GQLBuilder.Mutation (Maybe Article) CreateArticleInputs
createArticleMutation =
    let
        titleVar =
            Var.required "title" .title Var.string

        descVar =
            Var.required "desc" .desc Var.string

        categoryIdsVar =
            Var.optional "categoryIds" .categoryIds (Var.list Var.string) []
    in
        GQLBuilder.mutationDocument <|
            GQLBuilder.extract
                (GQLBuilder.field "addArticle"
                    [ ( "input"
                      , Arg.object
                            [ ( "title", Arg.variable titleVar )
                            , ( "desc", Arg.variable descVar )
                            , ( "category_ids", Arg.variable categoryIdsVar )
                            ]
                      )
                    ]
                    (GQLBuilder.extract <|
                        GQLBuilder.field "article"
                            []
                            (GQLBuilder.nullable articleObject)
                    )
                )


updateArticleMutation : GQLBuilder.Document GQLBuilder.Mutation (Maybe Article) UpdateArticleInputs
updateArticleMutation =
    let
        idVar =
            Var.required "id" .id Var.string

        titleVar =
            Var.required "title" .title Var.string

        descVar =
            Var.required "desc" .desc Var.string

        categoryIdVar =
            Var.optional "category_id" .categoryId Var.string ""

        urlIdVar =
            Var.optional "url_id" .urlId Var.string ""
    in
        GQLBuilder.mutationDocument <|
            GQLBuilder.extract
                (GQLBuilder.field "updateArticle"
                    [ ( "input"
                      , Arg.object
                            [ ( "id", Arg.variable idVar )
                            , ( "title", Arg.variable titleVar )
                            , ( "desc", Arg.variable descVar )
                            , ( "category_id", Arg.variable categoryIdVar )
                            , ( "url_id", Arg.variable urlIdVar )
                            ]
                      )
                    ]
                    (GQLBuilder.extract <|
                        GQLBuilder.field "article"
                            []
                            (GQLBuilder.nullable articleObject)
                    )
                )


deleteArticleMutation : GQLBuilder.Document GQLBuilder.Mutation UrlId { a | id : ArticleId }
deleteArticleMutation =
    let
        idVar =
            Var.required "id" .id Var.string
    in
        GQLBuilder.mutationDocument <|
            GQLBuilder.extract <|
                GQLBuilder.field "deleteArticle"
                    [ ( "input"
                      , Arg.object
                            [ ( "id", Arg.variable idVar ) ]
                      )
                    ]
                    (GQLBuilder.extract <|
                        GQLBuilder.field "deletedId"
                            []
                            GQLBuilder.string
                    )


articleStatusMutation : GQLBuilder.Document GQLBuilder.Mutation Article { vars | id : ArticleId, status : String }
articleStatusMutation =
    let
        idVar =
            Var.required "id" .id Var.string

        statusVar =
            Var.required "status" .status Var.string
    in
        GQLBuilder.mutationDocument <|
            GQLBuilder.extract <|
                GQLBuilder.field "updateArticleStatus"
                    [ ( "input"
                      , Arg.object
                            [ ( "id", Arg.variable idVar )
                            , ( "status", Arg.variable statusVar )
                            ]
                      )
                    ]
                    (GQLBuilder.extract <|
                        GQLBuilder.field "article"
                            []
                            articleObject
                    )


articleObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Article vars
articleObject =
    GQLBuilder.object Article
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "title" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "desc" [] GQLBuilder.string)
        |> (GQLBuilder.with (GQLBuilder.field "status" [] GQLBuilder.string))
        |> GQLBuilder.with
            (GQLBuilder.field "categories"
                []
                (GQLBuilder.list
                    categoryObject
                )
            )
        |> GQLBuilder.with
            (GQLBuilder.field "urls"
                []
                (GQLBuilder.list
                    urlObject
                )
            )


articleSummaryObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType ArticleSummary vars
articleSummaryObject =
    GQLBuilder.object ArticleSummary
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "title" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "status" [] GQLBuilder.string)


nullableArticleSummaryObject : GQLBuilder.ValueSpec GQLBuilder.Nullable GQLBuilder.ObjectType (Maybe ArticleSummary) vars
nullableArticleSummaryObject =
    GQLBuilder.nullable articleSummaryObject
