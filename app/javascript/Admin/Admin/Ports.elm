port module Admin.Ports exposing (..)

import Time exposing (Time)


-- INCOMING PORTS


port trixInitialize : (() -> msg) -> Sub msg


port trixChange : (String -> msg) -> Sub msg


port timeoutInitialized : (Int -> msg) -> Sub msg


port timedOut : (Int -> msg) -> Sub msg



-- port openArticle : (ArticleId -> msg) -> Sub msg
-- OUTGOING PORTS


port insertArticleContent : String -> Cmd msg


port removeTrixEditor : () -> Cmd msg


port setTimeout : Time -> Cmd msg


port clearTimeout : Int -> Cmd msg
