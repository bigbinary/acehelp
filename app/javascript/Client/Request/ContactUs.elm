module Request.ContactUs exposing (..)

import Http
import Task exposing (Task)
import Reader exposing (Reader)
import Data.ContactUs exposing (RequestMessage, ResponseMessage, getEncodedContact, decodeMessage)
import Request.Helpers exposing (..)


requestContactUs : Reader ( NodeEnv, ApiKey, RequestMessage ) (Task Http.Error ResponseMessage)
requestContactUs =
    Reader.Reader (\( env, apiKey, body ) -> Http.toTask (httpPost apiKey (apiUrl env "contacts") (Http.jsonBody <| getEncodedContact body) decodeMessage))
