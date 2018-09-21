module Admin.Request.Session exposing (requestLogin, requestResetPassword, signupRequest)

import Admin.Data.Session exposing (..)
import Admin.Data.User exposing (..)
import Admin.Request.Helper exposing (..)
import GraphQL.Client.Http as GQLClient
import GraphQL.Request.Builder as GQLBuilder
import Reader exposing (Reader)
import Task exposing (Task)


signupRequest : SignupInputs -> Reader ( NodeEnv, AppUrl ) (Task GQLClient.Error UserWithErrors)
signupRequest signupInputs =
    Reader.Reader
        (\( nodeEnv, appUrl ) ->
            GQLClient.customSendMutation
                { method = "POST"
                , url = graphqlUrl nodeEnv appUrl
                , headers = []
                , timeout = Nothing
                , withCredentials = False
                }
            <|
                GQLBuilder.request
                    { firstName = signupInputs.firstName
                    , email = signupInputs.email
                    , password = signupInputs.password
                    , confirmPassword = signupInputs.confirmPassword
                    }
                    signupMutation
        )


requestLogin :
    { a | email : String, password : String }
    -> Reader ( NodeEnv, AppUrl ) (Task GQLClient.Error UserWithOrganization)
requestLogin authInputs =
    Reader.Reader
        (\( nodeEnv, appUrl ) ->
            GQLClient.customSendMutation
                { method = "POST"
                , url = graphqlUrl nodeEnv appUrl
                , headers = []
                , timeout = Nothing
                , withCredentials = False
                }
            <|
                GQLBuilder.request
                    authInputs
                    loginMutation
        )


requestResetPassword :
    { a | email : String }
    -> Reader ( NodeEnv, AppUrl ) (Task GQLClient.Error ForgotPasswordResponse)
requestResetPassword emailInput =
    Reader.Reader
        (\( nodeEnv, appUrl ) ->
            GQLClient.customSendMutation
                { method = "POST"
                , url = graphqlUrl nodeEnv appUrl
                , headers = []
                , timeout = Nothing
                , withCredentials = False
                }
            <|
                GQLBuilder.request
                    emailInput
                    forgotPasswordMutation
        )
