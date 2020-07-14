module Spa.Document exposing
    ( Document
    , map
    , toBrowserDocument
    )

import Browser
import Html exposing (Html)


type alias Document msg =
    { title : String
    , body : List (Html msg)
    }


map : (msg1 -> msg2) -> Document msg1 -> Document msg2
map fn doc =
    { title = doc.title
    , body = List.map (Html.map fn) doc.body
    }


toBrowserDocument : Document msg -> Browser.Document msg
toBrowserDocument doc =
    { title = doc.title
    , body = doc.body
    }
