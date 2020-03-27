module Main exposing (main)

import Platform
import Ports


main :
    Program
        { command : String
        , name : String
        , pageType : String
        , filepaths : List String
        }
        ()
        Never
main =
    Platform.worker
        { init =
            \{ command, filepaths, name, pageType } ->
                ( ()
                , case command of
                    "build" ->
                        Ports.build filepaths

                    "add" ->
                        Ports.add { pageType = pageType, name = name }

                    _ ->
                        Ports.uhhh ()
                )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
