module Data.ContactUs exposing (GQLDataContact, ResponseMessage, RequestMessage, getEncodedContact, decodeMessage, encodeContactUs, decodeGQLDataContact)

import Json.Encode as Encode
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (decode, required, optional)


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


type alias GQLError =
    { message : String }


type alias GQLDataContact =
    { data : GQLContact }


type alias GQLContact =
    { addContact : GQLErrors
    }


type alias GQLErrors =
    { errors : List GQLError
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


encodeContactUs : RequestMessage -> Encode.Value
encodeContactUs { name, email, message } =
    let
        query =
            "mutation addContact { addContact(input: { name: \"" ++ name ++ "\" email: \"" ++ email ++ "\" message : \"" ++ message ++ "\"}){ errors{ message path }}}"
    in
        Encode.object
            [ ( "operationName", Encode.string "addContact" )
            , ( "query", Encode.string query )
            , ( "variables", Encode.object [] )
            ]



-- DECODERS


decodeMessage : Decoder ResponseMessage
decodeMessage =
    decode ResponseMessage
        |> optional "message" (Decode.map Just Decode.string) Nothing
        |> optional "errors" (Decode.map Just Decode.string) Nothing


decodeGQLDataContact : Decoder GQLDataContact
decodeGQLDataContact =
    decode GQLDataContact
        |> required "data" decodeGQLContact


decodeGQLContact : Decoder GQLContact
decodeGQLContact =
    decode GQLContact
        |> required "addContact" decodeGQLErrors


decodeGQLErrors : Decoder GQLErrors
decodeGQLErrors =
    decode GQLErrors
        |> optional "errors" (Decode.list decodeGQLError) []


decodeGQLError : Decoder GQLError
decodeGQLError =
    decode GQLError
        |> required "message" Decode.string
