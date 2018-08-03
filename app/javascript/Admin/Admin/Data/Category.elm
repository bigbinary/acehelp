module Admin.Data.Category exposing (..)

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


categoriesQuery : GQLBuilder.Document GQLBuilder.Query (List Category) vars
categoriesQuery =
    GQLBuilder.queryDocument
        (GQLBuilder.extract
            (GQLBuilder.field "categories"
                []
                (GQLBuilder.list
                    categoryObject
                )
            )
        )


categoryByIdQuery : GQLBuilder.Document GQLBuilder.Query Category { vars | id : String }
categoryByIdQuery =
    let
        idVar =
            Var.required "id" .id Var.string
    in
        GQLBuilder.queryDocument
            (GQLBuilder.extract
                (GQLBuilder.field "category"
                    [ ( "id", Arg.variable idVar ) ]
                    categoryObject
                )
            )


createCategoryMutation : GQLBuilder.Document GQLBuilder.Mutation Category CreateCategoryInputs
createCategoryMutation =
    let
        nameVar =
            Var.required "name" .name Var.string
    in
        GQLBuilder.mutationDocument <|
            GQLBuilder.extract <|
                GQLBuilder.field "category"
                    [ ( "name", Arg.variable nameVar )
                    ]
                    categoryObject


udpateCategoryMutation : GQLBuilder.Document GQLBuilder.Mutation Category UpdateCategoryInputs
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
                    (GQLBuilder.extract <|
                        GQLBuilder.field "category"
                            []
                            categoryObject
                    )


categoryObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Category vars
categoryObject =
    GQLBuilder.object Category
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
