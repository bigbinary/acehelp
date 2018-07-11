module Data.ContactUs exposing (ResponseMessage, RequestMessage, getEncodedContact, decodeMessage, addContactMutation)

import Json.Encode as Encode
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Data.Common exposing (..)


type alias ResponseMessage =
    { message : Maybe String
    , error : Maybe String
    }


type alias RequestContact =
    { contact : RequestMessage }


type alias RequestMessage =
    { name : String
    , email : String
    , message : String
    }



-- ENCODERS


getEncodedContact : RequestMessage -> Encode.Value
getEncodedContact requestMessage =
    encodeContact { contact = requestMessage }


encodeContact : RequestContact -> Encode.Value
encodeContact requestContact =
    Encode.object
        [ ( "contact", encodeMessage requestContact.contact ) ]


encodeMessage : RequestMessage -> Encode.Value
encodeMessage requestMessage =
    Encode.object
        [ ( "name", Encode.string requestMessage.name )
        , ( "email", Encode.string requestMessage.email )
        , ( "message", Encode.string requestMessage.message )
        ]


addContactMutation : GQLBuilder.Document GQLBuilder.Mutation (Maybe (List GQLError)) RequestMessage
addContactMutation =
    let
        nameVar =
            Var.required "name" .name Var.string

        emailVar =
            Var.required "email" .email Var.string

        messageVar =
            Var.required "message" .message Var.string

        article =
            GQLBuilder.extract <|
                GQLBuilder.field "errors"
                    []
                    (GQLBuilder.nullable
                        (GQLBuilder.list
                            (GQLBuilder.object GQLError
                                |> GQLBuilder.with (GQLBuilder.field "message" [] GQLBuilder.string)
                            )
                        )
                    )

        queryRoot =
            GQLBuilder.extract
                (GQLBuilder.field "addContact"
                    [ ( "input"
                      , Arg.object
                            [ ( "name", Arg.variable nameVar )
                            , ( "email", Arg.variable emailVar )
                            , ( "message", Arg.variable messageVar )
                            ]
                      )
                    ]
                    article
                )
    in
        GQLBuilder.mutationDocument queryRoot



-- DECODERS


decodeMessage : Decoder ResponseMessage
decodeMessage =
    decode ResponseMessage
        |> optional "message" (Decode.map Just Decode.string) Nothing
        |> optional "errors" (Decode.map Just Decode.string) Nothing
