module Internals.Transition exposing
    ( Options
    , Strategy
    , Transition(..)
    , custom
    , fade
    , none
    )

import Html exposing (Html, div)
import Html.Attributes as Attr


type Transition view
    = Transition (Options view)


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
fade speed =
    let
        transition =
            "opacity " ++ String.fromInt speed ++ "ms"

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
        { speed = speed
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
