module Application.Internals.Sandbox.Update exposing
    ( Update
    , create
    , keep
    , update
    )

import Application.Internals.Sandbox.Page as Page exposing (Page)


type Update model
    = Update model


create :
    (msg -> model -> Update model)
    -> msg
    -> model
    -> model
create fn msg model =
    fn msg model
        |> (\(Update result) -> result)


update :
    { page : Page pageModel pageMsg model msg
    , model : pageModel
    , msg : pageMsg
    }
    -> Update model
update config =
    let
        p =
            Page.unwrap config.page
    in
    Update
        (p.page.update config.msg config.model
            |> p.toModel
        )


keep : model -> Update model
keep =
    Update
