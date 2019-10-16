module Internals.Page exposing
    ( Page, Recipe, Bundle
    , Static, static
    , Sandbox, sandbox
    )

{-|

@docs Page, Recipe, Bundle

@docs Static, static

@docs Sandbox, sandbox

-}

import Html exposing (Html)


type alias Page pageModel pageMsg model msg =
    { toModel : pageModel -> model
    , toMsg : pageMsg -> msg
    }
    -> Recipe pageModel pageMsg model msg


type alias Recipe pageModel pageMsg model msg =
    { init : model
    , update : pageMsg -> pageModel -> model
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
    -> Page () Never model msg
static page { toModel, toMsg } =
    { init = toModel ()
    , update = always toModel
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
    -> Page pageModel pageMsg model msg
sandbox page { toModel, toMsg } =
    { init = toModel page.init
    , update =
        \msg model ->
            page.update msg model |> toModel
    , bundle =
        \model ->
            { view = page.view model |> Html.map toMsg
            }
    }
