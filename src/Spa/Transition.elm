module Spa.Transition exposing
    ( Transition
    , none, fadeHtml, fadeUi
    , custom
    )

{-|


## Create transitions from page to page!

A huge benefit to doing client-side rendering is the ability to
seamlessly navigate from one page to another!

This package is designed to make creating page transitions a breeze!

@docs Transition


# use one of these transitions

@docs none, fadeHtml, fadeUi


# ot roll your own

@docs custom

-}

import Element exposing (Element)
import Html exposing (Html)
import Internals.Path exposing (Path)
import Internals.Transition


{-| Describes how to move from one page to another.

    transition : Transition (Html msg)
    transition =
        Transition.none

    anotherTransition : Transition (Element msg)
    anotherTransition =
        Transition.fadeUi 300

-}
type alias Transition ui_msg =
    Internals.Transition.Transition ui_msg



-- TRANSITIONS


{-| Don't transition from one page to another

    transitions : Transitions (Html msg)
    transitions =
        { layout = Transition.none -- page loads instantly
        , page = Transition.fadeHtml 300
        , pages = []
        }

-}
none : Transition ui_msg
none =
    Internals.Transition.none


{-| Fade one page out and another one in. (For use with `elm/html`)

    Animation duration is represented in **milliseconds**

    transitions : Spa.Types.Transitions (Html msg)
    transitions =
        { layout = Transition.none
        , page = Transition.fadeHtml 300 -- 300 milliseconds
        , pages = []
        }

-}
fadeHtml : Int -> Transition (Html msg)
fadeHtml =
    Internals.Transition.fadeHtml


{-| Fade one page out and another one in. (For use with `mdgriffith/elm-ui`)

    Animation duration is represented in **milliseconds**

    transitions : Spa.Types.Transitions (Element msg)
    transitions =
        { layout = Transition.none
        , page = Transition.fadeUi 300 -- 300 milliseconds
        , pages = []
        }

-}
fadeUi : Int -> Transition (Element msg)
fadeUi =
    Internals.Transition.fadeUi


{-| Create your own custom transition!

Just provide three things:

  - How long (in milliseconds) the transition lasts.

  - What the page looks like when invisible.

  - What the page looks like when **visible**.

```
batmanNewspaper : Int -> Transition (Element msg)
batmanNewspaper duration =
    Transition.custom
        { duration = duration
        , invisible =
            \page ->
                el
                    [ alpha 0
                    , width fill
                    , rotate (4 * pi)
                    , scale 0
                    , Styles.transition
                        { property = "all"
                        , duration = duration
                        }
                    ]
                    page
        , visible =
            \page ->
                el
                    [ alpha 1
                    , width fill
                    , Styles.transition
                        { property = "all"
                        , duration = duration
                        }
                    ]
                    page
        }

--
-- using it later on
--
transitions : Spa.Types.Transitions (Element msg)
transitions =
    { layout = batmanNewspaper 500 -- 🦇
    , page = Transition.none
    , pages = []
    }
```

-}
custom :
    { duration : Int
    , invisible : View ui_msg
    , visible : View ui_msg
    }
    -> Transition ui_msg
custom =
    Internals.Transition.custom


type alias View ui_msg =
    ui_msg -> ui_msg
