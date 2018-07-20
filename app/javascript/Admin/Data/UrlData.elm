module Data.UrlData exposing (..)

import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias UrlId =
    String


type alias UrlData =
    { id : UrlId
    , url : String
    }


type alias CreateUrlInput =
    { url : String
    }


type alias UrlsListResponse =
    { urls : List UrlData
    }


requestUrlsQuery : GQLBuilder.Document GQLBuilder.Query (List UrlData) vars
requestUrlsQuery =
    GQLBuilder.queryDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "urls"
                []
                (GQLBuilder.list
                    (GQLBuilder.object UrlData
                        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                        |> GQLBuilder.with (GQLBuilder.field "url" [] GQLBuilder.string)
                    )
                )
            )


createUrlMutation : GQLBuilder.Document GQLBuilder.Mutation UrlData CreateUrlInput
createUrlMutation =
    let
        urlVar =
            Var.required "url" .url Var.string
    in
        GQLBuilder.mutationDocument <|
            GQLBuilder.extract <|
                GQLBuilder.field "addUrl"
                    [ ( "input"
                      , Arg.object
                            [ ( "url", Arg.variable urlVar ) ]
                      )
                    ]
                    (GQLBuilder.extract <|
                        GQLBuilder.field "url"
                            []
                            (GQLBuilder.object UrlData
                                |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                                |> GQLBuilder.with (GQLBuilder.field "url" [] GQLBuilder.string)
                            )
                    )
