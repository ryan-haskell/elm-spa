module Spa.Document exposing
    ( Document
    , map
    , toBrowserDocument
    )

import Browser
import Element exposing (..)


type alias Document msg =
    { title : String
    , body : List (Element msg)
    }


map : (msg1 -> msg2) -> Document msg1 -> Document msg2
map fn doc =
    { title = doc.title
    , body = List.map (Element.map fn) doc.body
    }


toBrowserDocument : Document msg -> Browser.Document msg
toBrowserDocument doc =
    { title = doc.title
    , body =
        [ Element.layout [ width fill, height fill ]
            (column [ width fill, height fill ] doc.body)
        ]
    }
