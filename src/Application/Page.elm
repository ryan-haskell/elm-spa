module Application.Page exposing
    ( element
    , page
    , sandbox
    , static
    )

import Internals.Context exposing (Context)
import Internals.Page as Internals


type alias Page route flags contextModel contextMsg model msg appModel appMsg element =
    Internals.Page route flags contextModel contextMsg model msg appModel appMsg element


static :
    { title : String
    , view : neverElement
    , toModel : () -> appModel
    , fromNever : neverElement -> element
    }
    -> Page route flags contextModel contextMsg () Never appModel appMsg element
static =
    Internals.static


sandbox :
    { title : model -> String
    , init : model
    , update : msg -> model -> model
    , view : model -> element
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }
    -> Page route flags contextModel contextMsg model msg appModel appMsg element
sandbox =
    Internals.sandbox


element :
    { title : model -> String
    , init : flags -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : model -> element
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }
    -> Page route flags contextModel contextMsg model msg appModel appMsg element
element =
    Internals.element


page :
    { title : Context flags route contextModel -> model -> String
    , init : Context flags route contextModel -> ( model, Cmd msg, Cmd contextMsg )
    , update : Context flags route contextModel -> msg -> model -> ( model, Cmd msg, Cmd contextMsg )
    , subscriptions : Context flags route contextModel -> model -> Sub msg
    , view : Context flags route contextModel -> model -> element
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }
    -> Page route flags contextModel contextMsg model msg appModel appMsg element
page =
    Internals.page
