module Internals.Transition exposing
    ( Transition
    , speed, view
    , optOut, none, fadeHtml, fadeUi, custom
    , Visibility
    , visible, invisible
    )

{-|

@docs Transition
@docs speed, view, chooseFrom
@docs optOut, none, fadeHtml, fadeUi

@docs Visibility
@docs visible, invisible

-}

import Element exposing (Element)
import Html exposing (Html)
import Html.Attributes as Attr
import Url exposing (Url)


type Visibility
    = Invisible
    | Visible


visible : Visibility
visible =
    Visible


invisible : Visibility
invisible =
    Invisible


type Transition ui_msg
    = OptOut
    | None
    | Transition (Options ui_msg)


type alias Options ui_msg =
    { speed : Int
    , invisible : View ui_msg
    , visible : View ui_msg
    }


type alias View ui_msg =
    { layout : ui_msg -> ui_msg
    , page : ui_msg
    }
    -> ui_msg


speed : Transition ui_msg -> Int
speed transition =
    case transition of
        OptOut ->
            0

        None ->
            0

        Transition t ->
            t.speed


view :
    Transition ui_msg
    -> Visibility
    ->
        { layout : ui_msg -> ui_msg
        , page : ui_msg
        }
    -> ui_msg
view transition visibility ({ layout, page } as record) =
    case transition of
        OptOut ->
            layout page

        None ->
            layout page

        Transition t ->
            case visibility of
                Visible ->
                    t.visible record

                Invisible ->
                    t.invisible record



-- TRANSITIONS


optOut : Transition ui_msg
optOut =
    OptOut


none : Transition ui_msg
none =
    None


fadeHtml : Int -> Transition (Html msg)
fadeHtml speed_ =
    let
        withOpacity : Int -> View (Html msg)
        withOpacity opacity { layout, page } =
            layout
                (Html.div
                    [ Attr.style "opacity" (String.fromInt opacity)
                    , Attr.style "transition" <|
                        String.concat
                            [ "opacity "
                            , String.fromInt speed_
                            , "ms ease-in-out"
                            ]
                    ]
                    [ page ]
                )
    in
    Transition <|
        { speed = speed_
        , invisible = withOpacity 0
        , visible = withOpacity 1
        }


fadeUi : Int -> Transition (Element msg)
fadeUi speed_ =
    let
        withOpacity : Float -> View (Element msg)
        withOpacity opacity { layout, page } =
            layout
                (Element.el
                    [ Element.width Element.fill
                    , Element.height Element.fill
                    , Element.alpha opacity
                    , Element.htmlAttribute <|
                        Attr.style "transition" <|
                            String.concat
                                [ "opacity "
                                , String.fromInt speed_
                                , "ms ease-in-out"
                                ]
                    ]
                    page
                )
    in
    Transition <|
        { speed = speed_
        , invisible = withOpacity 0
        , visible = withOpacity 1
        }

custom : 
    { speed : Int
    , invisible : View ui_msg
    , visible : View ui_msg
    } -> Transition ui_msg
custom =
    Transition