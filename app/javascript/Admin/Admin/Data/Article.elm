module Admin.Data.Article exposing
    ( Article
    , ArticleId
    , ArticleListResponse
    , ArticleResponse
    , ArticleSummary
    , CreateArticleInputs
    , TemporaryArticle
    , UpdateArticleInputs
    , allArticlesQuery
    , articleByIdQuery
    , articleObject
    , articleStatusMutation
    , articleSummaryObject
    , articlesByUrlQuery
    , createArticleMutation
    , deleteArticleMutation
    , nullableArticleSummaryObject
    , temporaryArticleQuery
    , updateArticleMutation
    )

import Admin.Data.Category exposing (Category, CategoryId, categoryObject)
import Admin.Data.Common exposing (..)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias ArticleId =
    String


type alias TemporaryArticle =
    { id : ArticleId
    }


type alias Article =
    { id : ArticleId
    , title : String
    , desc : String
    , status : String
    , categories : List Category
    , attachmentsPath : String
    }


type alias CreateArticleInputs =
    { id : Maybe ArticleId
    , title : String
    , desc : String
    , categoryIds : Maybe (List CategoryId)
    }


type alias UpdateArticleInputs =
    { id : ArticleId
    , title : String
    , desc : String
    , categoryIds : Maybe (List CategoryId)
    }


type alias ArticleSummary =
    { id : ArticleId
    , title : String
    , status : String
    }


type alias ArticleListResponse =
    { articles : List Article
    }


type alias ArticleResponse =
    { article : Maybe Article
    , errors : Maybe (List Error)
    }


articlesByUrlQuery :
    GQLBuilder.Document GQLBuilder.Query
        (Maybe (List ArticleSummary))
        { vars
            | url : String
        }
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


temporaryArticleQuery : GQLBuilder.Document GQLBuilder.Query (Maybe Article) {}
temporaryArticleQuery =
    GQLBuilder.queryDocument
        (GQLBuilder.extract
            (GQLBuilder.field "temporaryArticle"
                []
                (GQLBuilder.nullable articleObject)
            )
        )


createArticleMutation : GQLBuilder.Document GQLBuilder.Mutation ArticleResponse CreateArticleInputs
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
                articleResponseObject
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

        categoryIdsVar =
            Var.optional "categoryIds" .categoryIds (Var.list Var.string) []
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "updateArticle"
                [ ( "input"
                  , Arg.object
                        [ ( "id", Arg.variable idVar )
                        , ( "title", Arg.variable titleVar )
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


deleteArticleMutation : GQLBuilder.Document GQLBuilder.Mutation (Maybe ArticleId) { a | id : ArticleId }
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
                        (GQLBuilder.nullable GQLBuilder.string)
                )


articleStatusMutation :
    GQLBuilder.Document GQLBuilder.Mutation
        (Maybe Article)
        { vars
            | id : ArticleId
            , status : String
        }
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
                        (GQLBuilder.nullable articleObject)
                )


articleObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Article vars
articleObject =
    GQLBuilder.object Article
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "title" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "desc" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "status" [] GQLBuilder.string)
        |> GQLBuilder.with
            (GQLBuilder.field "categories"
                []
                (GQLBuilder.list
                    categoryObject
                )
            )
        |> GQLBuilder.with (GQLBuilder.field "attachments_path" [] GQLBuilder.string)


articleSummaryObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType ArticleSummary vars
articleSummaryObject =
    GQLBuilder.object ArticleSummary
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "title" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "status" [] GQLBuilder.string)


nullableArticleSummaryObject : GQLBuilder.ValueSpec GQLBuilder.Nullable GQLBuilder.ObjectType (Maybe ArticleSummary) vars
nullableArticleSummaryObject =
    GQLBuilder.nullable articleSummaryObject


articleResponseObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType ArticleResponse vars
articleResponseObject =
    GQLBuilder.object ArticleResponse
        |> GQLBuilder.with
            (GQLBuilder.field "article"
                []
                (GQLBuilder.nullable articleObject)
            )
        |> GQLBuilder.with errorsField
