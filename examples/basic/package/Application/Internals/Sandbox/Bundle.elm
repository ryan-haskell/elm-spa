module Application.Internals.Sandbox.Bundle exposing
    ( Bundle
    , bundle
    , createView
    )

import Application.Internals.Sandbox.Page as Page exposing (Page)
import Html exposing (Html)


type Bundle model msg
    = Bundle (Bundle_ model msg)


type alias Bundle_ model msg =
    { view : model -> Html msg
    }


createView :
    (model -> Bundle model msg)
    -> model
    -> Html msg
createView fn model =
    fn model
        |> (\(Bundle { view }) -> view model)


bundle :
    { page : Page pageModel pageMsg model msg
    , model : pageModel
    }
    -> Bundle model msg
bundle config =
    let
        p =
            Page.unwrap config.page
    in
    Bundle
        { view =
            always (p.page.view config.model)
                >> Html.map p.toMsg
        }
