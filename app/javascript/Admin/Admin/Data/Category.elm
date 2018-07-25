module Admin.Data.Category exposing (..)

import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Request.Builder.Arg as Arg


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


categoryObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Category vars
categoryObject =
    (GQLBuilder.object Category
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
    )
