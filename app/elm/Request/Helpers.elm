module Request.Helpers exposing (apiUrl)

-- Set True to access api calls from localhost


debug : Bool
debug =
    True


apiUrl : String -> String
apiUrl str =
    case debug of
        True ->
            "/api/v1/" ++ str

        False ->
            "https://staging.acehelp.com/api/v1/" ++ str
