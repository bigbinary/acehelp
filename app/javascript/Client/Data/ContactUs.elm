module Data.ContactUs exposing (ResponseMessage, RequestMessage, getEncodedContact, decodeMessage)

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



-- DECODERS


decodeMessage : Decoder ResponseMessage
decodeMessage =
    decode ResponseMessage
        |> optional "message" (Decode.map Just Decode.string) Nothing
        |> optional "error" (Decode.map Just Decode.string) Nothing
