module View exposing (View, map, none, placeholder, toBrowserDocument)

import Browser
import Html exposing (Html)
import Html.Attributes as Attr


type alias View msg =
    { title : String
    , body : List (Html msg)
    }


placeholder : String -> View msg
placeholder str =
    { title = str
    , body = [ Html.h1 [ Attr.class "h1" ] [ Html.text str ] ]
    }


none : View msg
none =
    placeholder ""


map : (a -> b) -> View a -> View b
map fn view =
    { title = view.title
    , body = List.map (Html.map fn) view.body
    }


toBrowserDocument : View msg -> Browser.Document msg
toBrowserDocument view =
    { title = view.title
    , body = view.body
    }
