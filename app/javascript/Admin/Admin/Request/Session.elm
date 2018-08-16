module Admin.Request.Session exposing (..)

import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Session exposing (..)
import Admin.Data.User exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


signupRequest : SignupInputs -> Reader ( NodeEnv, ApiKey ) (Task GQLClient.Error User)
signupRequest signupInputs =
    Reader.Reader
        (\( nodeEnv, apiKey ) ->
            GQLClient.customSendMutation (requestOptions nodeEnv apiKey) <|
                (GQLBuilder.request
                    { firstName = signupInputs.firstName
                    , email = signupInputs.email
                    , password = signupInputs.password
                    , confirmPassword = signupInputs.confirmPassword
                    }
                    signupMutation
                )
        )
