module Application.Transition exposing
    ( Transition
    , fade, none
    )

{-|

@docs Transition, Options, Strategy

@docs fade, none

-}

import Html exposing (Html, div)
import Html.Attributes as Attr


type alias Transition view =
    { speed : Int
    , strategy :
        { invisible : Views view -> view
        , partial : Views view -> view
        , visible : Views view -> view
        }
    }


type alias Views view =
    { layout : { page : view } -> view
    , page : view
    }


fade : Int -> Transition (Html msg)
fade speed_ =
    let
        transition =
            "opacity " ++ String.fromInt speed_ ++ "ms"

        styles =
            { invisible =
                [ Attr.style "height" "100%"
                , Attr.style "opacity" "0"
                , Attr.style "transition" transition
                ]
            , visible =
                [ Attr.style "height" "100%"
                , Attr.style "opacity" "1"
                , Attr.style "transition" transition
                ]
            }
    in
    { speed = speed_
    , strategy =
        { invisible =
            \{ layout, page } ->
                div styles.invisible
                    [ layout
                        { page = div styles.invisible [ page ]
                        }
                    ]
        , partial =
            \{ layout, page } ->
                div styles.visible
                    [ layout
                        { page = div styles.invisible [ page ]
                        }
                    ]
        , visible =
            \{ layout, page } ->
                div styles.visible
                    [ layout
                        { page = div styles.visible [ page ]
                        }
                    ]
        }
    }


none : Transition a
none =
    let
        passThrough { layout, page } =
            layout { page = page }
    in
    { speed = 0
    , strategy =
        { invisible = passThrough
        , partial = passThrough
        , visible = passThrough
        }
    }
