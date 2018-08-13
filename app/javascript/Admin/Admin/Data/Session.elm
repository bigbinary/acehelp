module Admin.Data.Session exposing (..)

import Admin.Data.User exposing (..)
import GraphQL.Request.Builder as GQLBuilder
import GraphQL.Request.Builder.Variable as Var
import GraphQL.Request.Builder.Arg as Arg


type alias SignupInputs =
    { firstName : String
    , email : String
    , password : String
    , confirmPassword : String
    }


signupMutation : GQLBuilder.Document GQLBuilder.Mutation User SignupInputs
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
                    (GQLBuilder.extract <|
                        GQLBuilder.field "user"
                            []
                            userObject
                    )
