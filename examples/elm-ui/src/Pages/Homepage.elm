module Pages.Homepage exposing (view)

import Element exposing (..)


view : Element Never
view =
    el [ centerX, centerY ]
        (text "Homepage!")
