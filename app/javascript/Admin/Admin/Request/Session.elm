module Admin.Request.Session exposing (..)

import Admin.Request.Helper exposing (..)
import Reader exposing (Reader)
import Task exposing (Task)
import Admin.Data.Session exposing (..)
import Admin.Data.User exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder


signupRequest : SignupInputs -> Reader NodeEnv (Task GQLClient.Error User)
signupRequest signupInputs =
    Reader.Reader
        (\nodeEnv ->
            GQLClient.customSendMutation
                ({ method = "POST"
                 , url = graphqlUrl nodeEnv
                 , headers = []
                 , timeout = Nothing
                 , withCredentials = False
                 }
                )
            <|
                (GQLBuilder.request
                    { firstName = signupInputs.firstName
                    , email = signupInputs.email
                    , password = signupInputs.password
                    , confirmPassword = signupInputs.confirmPassword
                    }
                    signupMutation
                )
        )


requestLogin : { a | email : String, password : String } -> Reader NodeEnv (Task GQLClient.Error String)
requestLogin authInputs =
    Reader.Reader
        (\nodeEnv ->
            GQLClient.customSendMutation
                ({ method = "POST"
                 , url = graphqlUrl nodeEnv
                 , headers = []
                 , timeout = Nothing
                 , withCredentials = False
                 }
                )
            <|
                (GQLBuilder.request
                    authInputs
                    loginMutation
                )
        )
