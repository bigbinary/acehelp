port module Admin.Ports exposing
    ( addAttachments
    , addPendingAction
    , clearTimeout
    , insertArticleContent
    , removePendingAction
    , setEditorHeight
    , setTimeout
    , timedOut
    , timeoutInitialized
    , trixInitialize
    )

-- INCOMING PORTS


port trixInitialize : (() -> msg) -> Sub msg


port timeoutInitialized : (Int -> msg) -> Sub msg


port timedOut : (Int -> msg) -> Sub msg


port addPendingAction : ({ id : String, message : String } -> msg) -> Sub msg


port removePendingAction : (String -> msg) -> Sub msg



-- port openArticle : (ArticleId -> msg) -> Sub msg
-- OUTGOING PORTS


port insertArticleContent : String -> Cmd msg


port addAttachments : () -> Cmd msg


port setTimeout : Int -> Cmd msg


port clearTimeout : Int -> Cmd msg


port setEditorHeight : { editorId : String, height : Float } -> Cmd msg
