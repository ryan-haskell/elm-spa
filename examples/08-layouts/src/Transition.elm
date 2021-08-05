module Transition exposing
    ( Attribute
    , apply
    , duration
    , invisible
    , visible
    )

import Html
import Html.Attributes as Attr
import View exposing (View)


type alias Attribute =
    Html.Attribute Never


duration : number
duration =
    500


invisible : List Attribute
invisible =
    [ Attr.class "fill-y", Attr.style "opacity" "0", Attr.style "transition" "opacity 500ms ease-in-out" ]


visible : List Attribute
visible =
    [ Attr.class "fill-y", Attr.style "opacity" "1", Attr.style "transition" "opacity 500ms ease-in-out" ]


apply : List Attribute -> View msg -> View msg
apply attrs view =
    { title = view.title
    , body =
        [ Html.div (List.map (Attr.map never) attrs) view.body
        ]
    }
