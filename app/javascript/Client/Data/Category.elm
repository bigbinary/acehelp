module Data.Category exposing (..)

import Json.Decode exposing (int, string, float, nullable, list, dict, Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional, hardcoded)
import Data.Article exposing (ArticleSummary, decodeArticleSummary, articleSummaryField)
import GraphQL.Request.Builder as GQLBuilder


type alias CategoryId =
    String


type alias Category =
    { id : CategoryId
    , name : String
    , articles : List ArticleSummary
    }


type alias Categories =
    { categories : List Category }



-- QUERIES


allCategoriesQuery : GQLBuilder.Document GQLBuilder.Query (List Category) vars
allCategoriesQuery =
    GQLBuilder.queryDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "categories"
                []
             <|
                GQLBuilder.list
                    (GQLBuilder.object Category
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "name" [] GQLBuilder.string)
                        |> GQLBuilder.with articleSummaryField
                    )
            )



-- DECODERS
