module Application.Internals.Element.Update exposing
    ( Update
    , create
    , keep
    , update
    )

import Application.Internals.Element.Page as Page exposing (Page)


type Update model msg
    = Update (Update_ model msg)


type alias Update_ model msg =
    ( model, Cmd msg )


create :
    (msg -> model -> Update model msg)
    -> msg
    -> model
    -> ( model, Cmd msg )
create fn msg model =
    fn msg model
        |> (\(Update result) -> result)


update :
    { page : Page flags pageModel pageMsg model msg
    , model : pageModel
    , msg : pageMsg
    }
    -> Update model msg
update config =
    let
        p =
            Page.unwrap config.page
    in
    Update
        (p.page.update config.msg config.model
            |> Tuple.mapBoth p.toModel (Cmd.map p.toMsg)
        )


keep : model -> Update model msg
keep model =
    Update ( model, Cmd.none )
