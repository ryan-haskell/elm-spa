module Spa.Transition exposing
    ( delays
    , properties
    )


delays : { layout : Int, page : Int }
delays =
    { layout = 300
    , page = 300
    }


properties : { layout : String, page : String }
properties =
    { layout = property delays.layout
    , page = property delays.page
    }


property : Int -> String
property delay =
    "opacity " ++ String.fromInt delay ++ "ms ease-in-out, visibility " ++ String.fromInt delay ++ "ms ease-in-out"
