module Admin.Data.Url exposing
    ( CreateUrlInput
    , UrlData
    , UrlId
    , UrlPattern
    , UrlResponse
    , UrlRule(..)
    , UrlsListResponse
    , createUrlMutation
    , dataToPattern
    , deleteUrlMutation
    , nullableUrlObject
    , requestUrlsQuery
    , ruleToString
    , stringToRule
    , updateUrlMutation
    , urlByIdQuery
    , urlObject
    , urlResponseObject
    )

import Admin.Data.Common exposing (..)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Monocle.Iso exposing (..)


type alias UrlId =
    String


type UrlRule
    = UrlIs String
    | UrlContains String
    | UrlEndsWith String


type alias UrlPattern =
    { id : UrlId
    , rule : UrlRule
    }


type alias UrlData =
    { id : UrlId
    , url_rule : String
    , url_pattern : String
    }


type alias CreateUrlInput =
    { url : String
    }


type alias UrlsListResponse =
    { urls : List UrlData
    }


type alias UrlResponse =
    { url : Maybe UrlData
    , errors : Maybe (List Error)
    }


ruleToString : UrlRule -> ( String, String )
ruleToString urlRule =
    case urlRule of
        UrlIs url ->
            ( "is", url )

        UrlContains url ->
            ( "contains", url )

        UrlEndsWith url ->
            ( "ends_with", url )


stringToRule : ( String, String ) -> Maybe UrlRule
stringToRule urlRule =
    case urlRule of
        ( "is", url ) ->
            Just <| UrlIs url

        ( "contains", url ) ->
            Just <| UrlContains url

        ( "ends_with", url ) ->
            Just <| UrlEndsWith url

        _ ->
            Nothing


dataToPattern : UrlData -> UrlPattern
dataToPattern urlData =
    { id = urlData.id
    , rule = Maybe.withDefault (UrlIs urlData.url_pattern) <| stringToRule ( urlData.url_rule, urlData.url_pattern )
    }


requestUrlsQuery : GQLBuilder.Document GQLBuilder.Query (Maybe (List UrlData)) vars
requestUrlsQuery =
    GQLBuilder.queryDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "urls"
                []
                (GQLBuilder.nullable
                    (GQLBuilder.list
                        urlObject
                    )
                )
            )


urlByIdQuery : GQLBuilder.Document GQLBuilder.Query (Maybe UrlData) { vars | id : String }
urlByIdQuery =
    let
        idVar =
            Var.required "id" .id Var.string
    in
    GQLBuilder.queryDocument
        (GQLBuilder.extract
            (GQLBuilder.field "url"
                [ ( "id", Arg.variable idVar ) ]
                nullableUrlObject
            )
        )


createUrlMutation : GQLBuilder.Document GQLBuilder.Mutation UrlResponse CreateUrlInput
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
                urlResponseObject


deleteUrlMutation : GQLBuilder.Document GQLBuilder.Mutation UrlId { a | id : UrlId }
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
                    GQLBuilder.field "deletedId"
                        []
                        GQLBuilder.string
                )


urlObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType UrlData vars
urlObject =
    GQLBuilder.object UrlData
        |> GQLBuilder.with (GQLBuilder.field "id" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "url_rule" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "url_pattern" [] GQLBuilder.string)


nullableUrlObject : GQLBuilder.ValueSpec GQLBuilder.Nullable GQLBuilder.ObjectType (Maybe UrlData) vars
nullableUrlObject =
    GQLBuilder.nullable urlObject


updateUrlMutation : GQLBuilder.Document GQLBuilder.Mutation UrlResponse UrlData
updateUrlMutation =
    let
        idVar =
            Var.required "id" .id Var.string

        urlRuleVar =
            Var.required "url_rule" .url_rule Var.string

        urlPatternVar =
            Var.required "url_pattern" .url_pattern Var.string
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract <|
            GQLBuilder.field "updateUrl"
                [ ( "input"
                  , Arg.object
                        [ ( "id", Arg.variable idVar )
                        , ( "url_rule", Arg.variable urlRuleVar )
                        , ( "url_pattern", Arg.variable urlPatternVar )
                        ]
                  )
                ]
                urlResponseObject


urlResponseObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType UrlResponse vars
urlResponseObject =
    GQLBuilder.object UrlResponse
        |> GQLBuilder.with
            (GQLBuilder.field "url"
                []
                (GQLBuilder.nullable urlObject)
            )
        |> GQLBuilder.with errorsField
