module Application.Internals.Element.Bundle exposing
    ( Bundle
    , bundle
    , createSubscriptions
    , createView
    )

import Application.Internals.Element.Page as Page exposing (Page)
import Html exposing (Html)


type Bundle model msg
    = Bundle (Bundle_ model msg)


type alias Bundle_ model msg =
    { view : model -> Html msg
    , subscriptions : model -> Sub msg
    }


createView :
    (model -> Bundle model msg)
    -> model
    -> Html msg
createView fn model =
    fn model
        |> (\(Bundle { view }) -> view model)


createSubscriptions :
    (model -> Bundle model msg)
    -> model
    -> Sub msg
createSubscriptions fn model =
    fn model
        |> (\(Bundle { subscriptions }) -> subscriptions model)


bundle :
    { page : Page flags pageModel pageMsg model msg
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
        , subscriptions =
            always (p.page.subscriptions config.model)
                >> Sub.map p.toMsg
        }
