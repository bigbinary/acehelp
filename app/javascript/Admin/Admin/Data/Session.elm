module Admin.Data.Session exposing (ForgotPasswordResponse, LoginData, SignupInputs, Token, forgotPasswordMutation, loginDataObject, loginMutation, logoutMutation, signupMutation, tokenObject)

import Admin.Data.Common exposing (..)
import Admin.Data.User exposing (..)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Arg as Arg
import GraphQL.Request.Builder.Variable as Var


type alias LoginData =
    { authentication_token : Token
    , user : UserWithOrganization
    }


type alias Token =
    { uid : String
    , access_token : String
    , client : String
    }


type alias SignupInputs =
    { firstName : String
    , email : String
    , password : String
    , confirmPassword : String
    }


type alias ForgotPasswordResponse =
    { status : Bool, errors : Maybe (List Error) }


signupMutation : GQLBuilder.Document GQLBuilder.Mutation UserWithErrors SignupInputs
signupMutation =
    let
        firstNameVar =
            Var.required "first_name" .firstName Var.string

        emailVar =
            Var.required "email" .email Var.string

        passwordVar =
            Var.required "password" .password Var.string

        confirmPasswordVar =
            Var.required "confirm_password" .confirmPassword Var.string
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract <|
            GQLBuilder.field "signup"
                [ ( "input"
                  , Arg.object
                        [ ( "first_name", Arg.variable firstNameVar )
                        , ( "email", Arg.variable emailVar )
                        , ( "password", Arg.variable passwordVar )
                        , ( "confirm_password", Arg.variable confirmPasswordVar )
                        ]
                  )
                ]
                userWithErrorObject


loginDataObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType LoginData vars
loginDataObject =
    GQLBuilder.object LoginData
        |> GQLBuilder.with
            (GQLBuilder.field
                "authentication_token"
                []
                tokenObject
            )
        |> GQLBuilder.with
            (GQLBuilder.field "user"
                []
                userWithOrganizationObject
            )


tokenObject : GQLBuilder.ValueSpec GQLBuilder.NonNull GQLBuilder.ObjectType Token vars
tokenObject =
    GQLBuilder.object Token
        |> GQLBuilder.with (GQLBuilder.field "access_token" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "uid" [] GQLBuilder.string)
        |> GQLBuilder.with (GQLBuilder.field "client" [] GQLBuilder.string)


loginMutation : GQLBuilder.Document GQLBuilder.Mutation UserWithOrganization { a | email : String, password : String }
loginMutation =
    let
        emailVar =
            Var.required "email" .email Var.string

        passwordVar =
            Var.required "password" .password Var.string
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "loginUser"
                [ ( "input"
                  , Arg.object
                        [ ( "email", Arg.variable emailVar )
                        , ( "password", Arg.variable passwordVar )
                        ]
                  )
                ]
                (GQLBuilder.extract <|
                    GQLBuilder.field "user"
                        []
                        userWithOrganizationObject
                )
            )


forgotPasswordMutation : GQLBuilder.Document GQLBuilder.Mutation ForgotPasswordResponse { a | email : String }
forgotPasswordMutation =
    let
        emailVar =
            Var.required "email" .email Var.string
    in
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "forgotPassword"
                [ ( "input"
                  , Arg.object
                        [ ( "email", Arg.variable emailVar )
                        ]
                  )
                ]
                (GQLBuilder.object ForgotPasswordResponse
                    |> GQLBuilder.with
                        (GQLBuilder.field "status"
                            []
                            GQLBuilder.bool
                        )
                    |> GQLBuilder.with
                        (GQLBuilder.field "errors"
                            []
                            (GQLBuilder.nullable
                                (GQLBuilder.list errorObject)
                            )
                        )
                )
            )


logoutMutation : GQLBuilder.Document GQLBuilder.Mutation String {}
logoutMutation =
    GQLBuilder.mutationDocument <|
        GQLBuilder.extract
            (GQLBuilder.field "logoutUser"
                []
                (GQLBuilder.extract <|
                    GQLBuilder.field "status" [] GQLBuilder.string
                )
            )
