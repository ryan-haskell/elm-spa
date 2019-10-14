module Application.Internals.Element.Init exposing
    ( Init
    , create
    , init
    )

import Application.Internals.Element.Page as Page exposing (Page)


type Init flags model msg
    = Init (Init_ flags model msg)


type alias Init_ flags model msg =
    flags -> ( model, Cmd msg )


init :
    Page flags pageModel pageMsg model msg
    -> Init flags model msg
init page =
    let
        p =
            Page.unwrap page
    in
    Init
        (\flags ->
            p.page.init flags
                |> Tuple.mapBoth p.toModel (Cmd.map p.toMsg)
        )


create :
    Init flags model msg
    -> flags
    -> ( model, Cmd msg )
create (Init fn) =
    fn
