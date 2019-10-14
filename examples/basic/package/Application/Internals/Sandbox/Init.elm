module Application.Internals.Sandbox.Init exposing
    ( Init
    , create
    , init
    )

import Application.Internals.Sandbox.Page as Page exposing (Page)


type Init model
    = Init model


init :
    Page pageModel pageMsg model msg
    -> Init model
init page =
    let
        p =
            Page.unwrap page
    in
    Init (p.page.init |> p.toModel)


create :
    Init model
    -> model
create (Init value) =
    value
