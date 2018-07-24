module Data.ContactUs exposing (FeedbackForm, ResponseMessage, RequestMessage, getEncodedContact, decodeMessage, addTicketMutation, addFeedbackMutation)

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


type alias FeedbackForm =
    { comment : String
    , email : String
    , name : String
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

addFeedbackMutation : GQLBuilder.Document GQLBuilder.Mutation (Maybe (List GQLError)) FeedbackForm
addFeedbackMutation =
    let
        guestNameVar =
            Var.required "name" .name Var.string

        guestMessageVar =
            Var.required "message" .comment Var.string
    in
        GQLBuilder.mutationDocument <|
            GQLBuilder.extract <|
                GQLBuilder.field "addFeedback"
                    [ ( "input"
                      , Arg.object
                          [ ("name", Arg.variable guestNameVar )
                          , ("message", Arg.variable guestMessageVar )
                          ]
                      )
                    ]
                    errorsExtractor
-- DECODERS


decodeMessage : Decoder ResponseMessage
decodeMessage =
    decode ResponseMessage
        |> optional "message" (Decode.map Just Decode.string) Nothing
        |> optional "errors" (Decode.map Just Decode.string) Nothing
