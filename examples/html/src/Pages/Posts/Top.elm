module Pages.Posts.Top exposing
    ( Flags
    , Model
    , Msg
    , page
    )

import Html exposing (..)
import Html.Attributes as Attr exposing (class, href)
import Page exposing (Document, Page)


type alias Flags =
    ()


type alias Model =
    ()


type alias Msg =
    Never


page : Page Flags Model Msg
page =
    Page.static
        { view = view
        }


view : Document Msg
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
