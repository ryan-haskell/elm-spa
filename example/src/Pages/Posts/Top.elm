module Pages.Posts.Top exposing
    ( Flags
    , Model
    , Msg
    , page
    )

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes as Attr exposing (class, href)
import Spa exposing (Page)


type alias Flags =
    ()


type alias Model =
    ()


type alias Msg =
    Never


page : Page Flags Model Msg globalModel globalMsg
page =
    Spa.static
        { view = view
        }


view : Document msg
view =
    { title = "Posts"
    , body =
        [ h1 [ class "font--h1" ] [ text "Posts" ]
        , ul []
            [ li [] [ a [ class "link", href "/posts/1" ] [ text "The first post" ] ]
            , li [] [ a [ class "link", href "/posts/2" ] [ text "The second post" ] ]
            , li [] [ a [ class "link", href "/posts/3" ] [ text "The last post" ] ]
            ]
        ]
    }
