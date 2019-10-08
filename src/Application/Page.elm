module Application.Page exposing
    ( static
    , sandbox
    , element
    , page
    )

{-| The `Page` type builds simple or complex pages,

based on your use case. The naming conventions are inspired by the
[`elm/browser`](#) package.


## Warning: The types here look spooky! 👻

But they they're much less spooky in practice. You got this!

For the following examples, lets imagine this is our top level `Model` and
`Msg`

    type Model
        = HomepageModel ()
        | CounterModel Pages.Counter.Model
        | RandomModel Pages.Random.Model
        | SignInModel Pages.SignIn.Model
        | NotFoundModel ()

    type Msg
        = HomepageMsg Never
        | CounterMsg Pages.Counter.Msg
        | RandomMsg Pages.Random.Msg
        | SignInMsg Pages.SignIn.Msg
        | NotFoundMsg Never

**Note:** static pages use `()` and `Never` for their `Model` and `Msg` because
they have no model ( the `()` part ) and can't send messages ( the `Never` part ).

Having them accept arguments helps make the rest of the code more consistent 😎


# Static

A static page that doesn't need to send messages or make updates to the app.

@docs static


# Sandbox

A sandbox page that can make messages, but doesn't need to produce any side effects.

@docs sandbox


# Element

An element page that makes messages that might produce side effects.

@docs element


# Page

An complete page that needs access to the shared application state (context) and might produce side effects for the page _or_ the application.

@docs page

-}

import Html exposing (Html)
import Internals.Context exposing (Context)
import Internals.Page as Internals


type alias Page route flags contextModel contextMsg model msg appModel appMsg =
    Internals.Page route flags contextModel contextMsg model msg appModel appMsg


{-|

    homepage =
        Page.static
            { title = Pages.Homepage.title
            , view = Pages.Homepage.view
            , toModel = HomepageModel
            }

-}
static :
    { title : String
    , view : Html Never
    , toModel : () -> appModel
    }
    -> Page route flags contextModel contextMsg () Never appModel appMsg
static =
    Internals.static


{-|

    counter =
        Page.sandbox
            { title = Pages.Counter.title
            , init = Pages.Counter.init
            , update = Pages.Counter.update
            , view = Pages.Counter.view
            , toModel = CounterModel
            , toMsg = CounterMsg
            }

-}
sandbox :
    { title : model -> String
    , init : model
    , update : msg -> model -> model
    , view : model -> Html msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }
    -> Page route flags contextModel contextMsg model msg appModel appMsg
sandbox =
    Internals.sandbox


{-|

    random =
        Page.element
            { title = Pages.Random.title
            , init = Pages.Random.init
            , update = Pages.Random.update
            , subscriptions = Pages.Random.subscriptions
            , view = Pages.Random.view
            , toModel = RandomModel
            , toMsg = RandomMsg
            }

-}
element :
    { title : model -> String
    , init : flags -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , subscriptions : model -> Sub msg
    , view : model -> Html msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }
    -> Page route flags contextModel contextMsg model msg appModel appMsg
element =
    Internals.element


{-|

    signIn =
        Page.page
            { title = Pages.SignIn.title
            , init = Pages.SignIn.init
            , update = Pages.SignIn.update
            , subscriptions = Pages.SignIn.subscriptions
            , view = Pages.SignIn.view
            , toModel = SignInModel
            , toMsg = SignInMsg
            }

-}
page :
    { title : Context flags route contextModel -> model -> String
    , init : Context flags route contextModel -> ( model, Cmd msg, Cmd contextMsg )
    , update : Context flags route contextModel -> msg -> model -> ( model, Cmd msg, Cmd contextMsg )
    , subscriptions : Context flags route contextModel -> model -> Sub msg
    , view : Context flags route contextModel -> model -> Html msg
    , toMsg : msg -> appMsg
    , toModel : model -> appModel
    }
    -> Page route flags contextModel contextMsg model msg appModel appMsg
page =
    Internals.page
