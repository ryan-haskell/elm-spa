module Utils.Cmd exposing
    ( pure
    , toCmd
    )

import Task


pure : model -> ( model, Cmd a, Cmd b )
pure model =
    ( model
    , Cmd.none
    , Cmd.none
    )


toCmd : msg -> Cmd msg
toCmd msg =
    Task.perform identity (Task.succeed msg)
