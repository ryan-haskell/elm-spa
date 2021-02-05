module Effect exposing
    ( Effect, none, map, batch
    , fromCmd, fromShared
    , toCmd
    )

{-|

@docs Effect, none, map, batch
@docs fromCmd, fromShared
@docs toCmd

-}

import Shared
import Task


type Effect msg
    = None
    | Cmd (Cmd msg)
    | Shared Shared.Msg
    | Batch (List (Effect msg))


none : Effect msg
none =
    None


map : (a -> b) -> Effect a -> Effect b
map fn effect =
    case effect of
        None ->
            None

        Cmd cmd ->
            Cmd (Cmd.map fn cmd)

        Shared msg ->
            Shared msg

        Batch list ->
            Batch (List.map (map fn) list)


fromCmd : Cmd msg -> Effect msg
fromCmd =
    Cmd


fromShared : Shared.Msg -> Effect msg
fromShared =
    Shared


batch : List (Effect msg) -> Effect msg
batch =
    Batch



-- Used by Main.elm


toCmd : ( Shared.Msg -> msg, pageMsg -> msg ) -> Effect pageMsg -> Cmd msg
toCmd ( fromSharedMsg, fromPageMsg ) effect =
    case effect of
        None ->
            Cmd.none

        Cmd cmd ->
            Cmd.map fromPageMsg cmd

        Shared msg ->
            Task.succeed msg
                |> Task.perform fromSharedMsg

        Batch list ->
            Cmd.batch (List.map (toCmd ( fromSharedMsg, fromPageMsg )) list)
