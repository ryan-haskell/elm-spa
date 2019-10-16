module Internals.Page exposing
    ( Page, Bundle
    , Static, static
    , Sandbox, sandbox
    )

{-|

@docs Page, Bundle

@docs Static, static

@docs Sandbox, sandbox

-}

import Html exposing (Html)


type alias Page pageModel pageMsg model msg =
    { init : model
    , update : pageMsg -> pageModel -> model
    , keep : model -> model
    , bundle : pageModel -> Bundle msg
    }


type alias Bundle msg =
    { view : Html msg
    }



-- STATIC


type alias Static =
    { view : Html Never
    }


static :
    Static
    ->
        { toModel : () -> model
        , toMsg : Never -> msg
        }
    -> Page () Never model msg
static page { toModel, toMsg } =
    { init = toModel ()
    , update = always toModel
    , keep = identity
    , bundle =
        always
            { view = Html.map toMsg page.view
            }
    }



-- SANDBOX


type alias Sandbox pageModel pageMsg =
    { init : pageModel
    , update : pageMsg -> pageModel -> pageModel
    , view : pageModel -> Html pageMsg
    }


sandbox :
    Sandbox pageModel pageMsg
    ->
        { toModel : pageModel -> model
        , toMsg : pageMsg -> msg
        }
    -> Page pageModel pageMsg model msg
sandbox page { toModel, toMsg } =
    { init = toModel page.init
    , update = \msg model -> page.update msg model |> toModel
    , keep = identity
    , bundle =
        \model ->
            { view = page.view model |> Html.map toMsg
            }
    }
