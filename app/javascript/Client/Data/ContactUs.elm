module Data.ContactUs exposing (FeedbackForm, RequestMessage, ResponseMessage, addTicketMutation, decodeMessage, getEncodedContact)

import Data.Common exposing (..)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (optional, required)
import Json.Encode as Encode


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


type alias FeedbackForm =
    { comment : String
    , email : String
    , name : String
    , article_id : String
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


addTicketMutation : GQLBuilder.Document GQLBuilder.Mutation (Maybe (List GQLError)) FeedbackForm
addTicketMutation =
    let
        nameVar =
            Var.required "name" .name Var.string

        emailVar =
            Var.required "email" .email Var.string

        messageVar =
            Var.required "message" .comment Var.string
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract <|
            GQLBuilder.field "addTicket"
                [ ( "input"
                  , Arg.object
                        [ ( "name", Arg.variable nameVar )
                        , ( "email", Arg.variable emailVar )
                        , ( "message", Arg.variable messageVar )
                        ]
                  )
                ]
                errorsExtractor



-- DECODERS


decodeMessage : Decoder ResponseMessage
decodeMessage =
    Decode.succeed ResponseMessage
        |> optional "message" (Decode.map Just Decode.string) Nothing
        |> optional "errors" (Decode.map Just Decode.string) Nothing
