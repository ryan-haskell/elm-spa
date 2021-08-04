module Transition exposing (Transition, layout, page)


type alias Transition attr =
    { duration : Int
    , invisible : List attr
    , visible : List attr
    }


layout : Transition attr
layout =
    { duration = 0
    , invisible = []
    , visible = []
    }


page : Transition attr
page =
    { duration = 0
    , invisible = []
    , visible = []
    }
