module Admin.Data.Url exposing (..)

import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias UrlId =
    String


type alias UrlData =
    { id : UrlId
    , url : String
    }


type alias UrlIdInput =
    { id : String
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
                    urlExtractor
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
                            urlExtractor
                    )


deleteUrlMutation : GQLBuilder.Document GQLBuilder.Mutation UrlIdInput UrlIdInput
deleteUrlMutation =
    let
        idVar =
            Var.required "id" .id Var.string
    in
        GQLBuilder.mutationDocument <|
            GQLBuilder.extract <|
                GQLBuilder.field "deleteUrl"
                    [ ( "input"
                      , Arg.object
                            [ ( "id", Arg.variable idVar ) ]
                      )
                    ]
                    (GQLBuilder.extract <|
                        GQLBuilder.field "id"
                            []
                            (GQLBuilder.object UrlIdInput
                                |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
                            )
                    )


urlExtractor : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType UrlData vars
urlExtractor =
    (GQLBuilder.object UrlData
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "url" [] GQLBuilder.string)
    )
