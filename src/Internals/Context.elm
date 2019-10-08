module Internals.Context exposing (Context)


type alias Context flags route contextModel =
    { flags : flags
    , route : route
    , context : contextModel
    }
