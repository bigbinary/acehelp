module Admin.Data.Category exposing
    ( Category
    , CategoryId
    , CategoryList
    , CategoryName
    , CategoryResponse
    , CreateCategoryInputs
    , DeleteCategoryInput
    , UpdateCategoryInputs
    , categoriesQuery
    , categoryByIdQuery
    , categoryObject
    , createCategoryMutation
    , deleteCategoryMutation
    , udpateCategoryMutation
    , updateCategoryStatusMutation
    )

import Admin.Data.Common exposing (..)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias CategoryId =
    String


type alias CategoryName =
    String


type alias Category =
    { id : CategoryId
    , name : CategoryName
    , status : String
    }


type alias CategoryList =
    { categories : List Category
    }


type alias CreateCategoryInputs =
    { name : CategoryName
    }


type alias UpdateCategoryInputs =
    { id : CategoryId
    , name : CategoryName
    }


type alias DeleteCategoryInput =
    { id : CategoryId
    }


type alias CategoryResponse =
    { category : Maybe Category
    , errors : Maybe (List Error)
    }


categoriesQuery : GQLBuilder.Document GQLBuilder.Query (Maybe (List Category)) vars
categoriesQuery =
    GQLBuilder.queryDocument
        (GQLBuilder.extract
            (GQLBuilder.field "categories"
                []
                (GQLBuilder.nullable
                    (GQLBuilder.list
                        categoryObject
                    )
                )
            )
        )


categoryByIdQuery : GQLBuilder.Document GQLBuilder.Query (Maybe Category) { vars | id : String }
categoryByIdQuery =
    let
        idVar =
            Var.required "id" .id Var.string
    in
    GQLBuilder.queryDocument
        (GQLBuilder.extract
            (GQLBuilder.field "category"
                [ ( "id", Arg.variable idVar ) ]
                (GQLBuilder.nullable
                    categoryObject
                )
            )
        )


createCategoryMutation : GQLBuilder.Document GQLBuilder.Mutation CategoryResponse CreateCategoryInputs
createCategoryMutation =
    let
        nameVar =
            Var.required "name" .name Var.string
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract <|
            GQLBuilder.field "addCategory"
                [ ( "input"
                  , Arg.object [ ( "name", Arg.variable nameVar ) ]
                  )
                ]
                categoryResponseObject


udpateCategoryMutation : GQLBuilder.Document GQLBuilder.Mutation CategoryResponse UpdateCategoryInputs
udpateCategoryMutation =
    let
        idVar =
            Var.required "id" .id Var.string

        nameVar =
            Var.required "name" .name Var.string
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract <|
            GQLBuilder.field "updateCategory"
                [ ( "input"
                  , Arg.object
                        [ ( "id", Arg.variable idVar )
                        , ( "category"
                          , Arg.object
                                [ ( "name", Arg.variable nameVar )
                                ]
                          )
                        ]
                  )
                ]
                categoryResponseObject


categoryObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Category vars
categoryObject =
    GQLBuilder.object Category
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "status" [] GQLBuilder.string)


categoryResponseObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType CategoryResponse vars
categoryResponseObject =
    GQLBuilder.object CategoryResponse
        |> GQLBuilder.with
            (GQLBuilder.field "category"
                []
                (GQLBuilder.nullable categoryObject)
            )
        |> GQLBuilder.with errorsField


deleteCategoryMutation : GQLBuilder.Document GQLBuilder.Mutation (Maybe CategoryId) DeleteCategoryInput
deleteCategoryMutation =
    let
        idVar =
            Var.required "id" .id Var.string
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract <|
            GQLBuilder.field "deleteCategory"
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


updateCategoryStatusMutation :
    GQLBuilder.Document GQLBuilder.Mutation
        (Maybe (List Category))
        { vars
            | id : String
            , status : String
        }
updateCategoryStatusMutation =
    let
        idVar =
            Var.required "id" .id Var.string

        statusVar =
            Var.required "status" .status Var.string
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract <|
            GQLBuilder.field "changeCategoryStatus"
                [ ( "input"
                  , Arg.object
                        [ ( "id", Arg.variable idVar )
                        , ( "status", Arg.variable statusVar )
                        ]
                  )
                ]
                (GQLBuilder.extract <|
                    GQLBuilder.field "categories"
                        []
                        (GQLBuilder.nullable
                            (GQLBuilder.list
                                categoryObject
                            )
                        )
                )
