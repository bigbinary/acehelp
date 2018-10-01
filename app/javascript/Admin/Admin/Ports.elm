port module Admin.Ports exposing
    ( clearTimeout
    , insertArticleContent
    , setEditorHeight
    , setTimeout
    , timedOut
    , timeoutInitialized
    , trixChange
    , trixInitialize
    )

-- INCOMING PORTS


port trixInitialize : (() -> msg) -> Sub msg


port trixChange : (String -> msg) -> Sub msg


port timeoutInitialized : (Int -> msg) -> Sub msg


port timedOut : (Int -> msg) -> Sub msg



-- port openArticle : (ArticleId -> msg) -> Sub msg
-- OUTGOING PORTS


port insertArticleContent : String -> Cmd msg


port setTimeout : Int -> Cmd msg


port clearTimeout : Int -> Cmd msg


port setEditorHeight : { editorId : String, height : Float } -> Cmd msg
