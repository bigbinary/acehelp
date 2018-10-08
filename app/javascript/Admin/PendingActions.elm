module PendingActions exposing
    ( PendingActions
    , add
    , empty
    , isEmpty
    , messages
    , remove
    , without
    )


type PendingActions
    = PendingActions (List Action)


type alias Action =
    { id : String, message : String }


add : String -> String -> PendingActions -> PendingActions
add id message pendingActions =
    if exists id pendingActions then
        pendingActions

    else
        case pendingActions of
            PendingActions actions ->
                (Action id message :: actions)
                    |> PendingActions


exists : String -> PendingActions -> Bool
exists id pendingActions =
    case pendingActions of
        PendingActions actions ->
            actions
                |> List.any (\action -> action.id == id)


remove : String -> PendingActions -> PendingActions
remove =
    without


without : String -> PendingActions -> PendingActions
without id pendingActions =
    case pendingActions of
        PendingActions actions ->
            actions
                |> List.filter (\action -> action.id /= id)
                |> PendingActions


empty : PendingActions
empty =
    PendingActions []


messages : PendingActions -> List String
messages pendingActions =
    case pendingActions of
        PendingActions actions ->
            actions |> List.map .message


isEmpty : PendingActions -> Bool
isEmpty pendingActions =
    case pendingActions of
        PendingActions actions ->
            List.isEmpty actions
