port module Admin.Ports exposing (..)

-- INCOMING PORTS


port trixInitialize : (() -> msg) -> Sub msg


port trixChange : (String -> msg) -> Sub msg



-- port openArticle : (ArticleId -> msg) -> Sub msg
-- OUTGOING PORTS


port insertArticleContent : String -> Cmd msg
