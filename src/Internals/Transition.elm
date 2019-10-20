module Internals.Transition exposing
    ( Transition, Options, Strategy
    , fade, custom, none
    , speed, strategy
    )

{-|

@docs Transition, Options, Strategy

@docs fade, custom, none

@docs speed strategy

-}

import Html exposing (Html, div)
import Html.Attributes as Attr


type Transition view
    = Transition (Options view)


unwrap : Transition view -> Options view
unwrap (Transition options) =
    options


speed : Transition view -> Int
speed =
    unwrap >> .speed


strategy : Transition view -> Strategy view
strategy =
    unwrap >> .strategy


type alias Options view =
    { speed : Int
    , strategy : Strategy view
    }


type alias Strategy view =
    { beforeLoad : Views view -> view
    , leavingPage : Views view -> view
    , enteringPage : Views view -> view
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
    Transition
        { speed = speed_
        , strategy =
            { beforeLoad =
                \{ layout, page } ->
                    div styles.invisible
                        [ layout
                            { page = div styles.invisible [ page ]
                            }
                        ]
            , leavingPage =
                \{ layout, page } ->
                    div styles.visible
                        [ layout
                            { page = div styles.invisible [ page ]
                            }
                        ]
            , enteringPage =
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
        view { layout, page } =
            layout { page = page }
    in
    Transition
        { speed = 0
        , strategy =
            { beforeLoad = view
            , leavingPage = view
            , enteringPage = view
            }
        }


custom : Options a -> Transition a
custom =
    Transition
