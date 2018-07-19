module Request.CategoryRequest exposing (..)

import Http
import Data.CategoryData exposing (..)
import Request.RequestHelper exposing (..)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Request.Builder.Arg as Arg


categoryListUrl : NodeEnv -> Url
categoryListUrl env =
    (baseUrl env) ++ "/api/v1/all"


requestCategories : NodeEnv -> ApiKey -> Http.Request CategoryList
requestCategories env apiKey =
    let
        requestData =
            { method = "GET"
            , params = []
            , url = categoryListUrl env
            , body = Http.emptyBody
            , nodeEnv = env
            , organizationApiKey = apiKey
            }
    in
        httpRequest requestData categoryListDecoder


categoriesQuery : GQLBuilder.Document GQLBuilder.Query (List Category) vars
categoriesQuery =
    GQLBuilder.queryDocument
        (GQLBuilder.extract
            (GQLBuilder.field "categories"
                []
                (GQLBuilder.list
                    (GQLBuilder.object Category
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
                    )
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
                    (GQLBuilder.object Category
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
                    )
