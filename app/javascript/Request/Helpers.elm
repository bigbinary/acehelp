module Request.Helpers exposing (apiUrl)

-- Set True to access api calls from localhost


apiUrl : String -> String -> String
apiUrl env str =
    case env of
        "production" ->
            "https://staging.acehelp.com/api/v1/" ++ str

        _ ->
            -- If it is development environment or anything else fall back to local/relative api path
            "/api/v1/" ++ str
