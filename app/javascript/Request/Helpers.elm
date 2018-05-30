module Request.Helpers exposing (apiUrl, url)

import Http exposing (encodeUri)


-- Set True to access api calls from localhost


apiUrl : String -> String -> String
apiUrl env str =
    case env of
        "production" ->
            "https://staging.acehelp.com/api/v1/" ++ str

        _ ->
            -- If it is development environment or anything else fall back to local/relative api path
            "/api/v1/" ++ str


url : String -> List ( String, String ) -> String
url baseUrl queryParams =
    case queryParams of
        [] ->
            baseUrl

        _ ->
            baseUrl ++ "?" ++ String.join "&" (List.map (\( key, value ) -> encodeUri key ++ "=" ++ encodeUri value) queryParams)
