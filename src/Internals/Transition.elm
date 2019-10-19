module Internals.Transition exposing
    ( Transitionable(..), unwrap, begin, complete
    , Strategy, Options, fade, none
    )

{-|

@docs Transitionable, unwrap, begin, complete

@docs Strategy, Options, fade, none

-}

import Html exposing (Html, div)
import Html.Attributes as Attr


type Transitionable a
    = Ready a
    | Transitioning a
    | Complete a


unwrap : Transitionable a -> a
unwrap transitionable =
    case transitionable of
        Ready value ->
            value

        Transitioning value ->
            value

        Complete value ->
            value


begin : Transitionable a -> Transitionable a
begin =
    unwrap >> Transitioning


complete : Transitionable a -> Transitionable a
complete =
    unwrap >> Complete


type alias Options view =
    { beforeLoad : Views view -> view
    , leavingPage : Views view -> view
    , enteringPage : Views view -> view
    }


type alias Views view =
    { layout : { page : view } -> view
    , page : view
    }


type alias Strategy view =
    Int -> Options view


fade : Strategy (Html msg)
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


none : Strategy a
none _ =
    let
        view { layout, page } =
            layout { page = page }
    in
    { beforeLoad = view
    , leavingPage = view
    , enteringPage = view
    }
