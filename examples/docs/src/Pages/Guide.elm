module Pages.Guide exposing (Model, Msg, page)

import Components.Hero as Hero
import Element exposing (..)
import Generated.Params as Params
import Spa.Page
import Ui
import Utils.Spa exposing (Page)


type alias Model =
    ()


type alias Msg =
    Never


page : Page Params.Guide Model Msg model msg appMsg
page =
    Spa.Page.static
        { title = always "guide | elm-spa"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    Ui.sections
        [ Hero.view
            { title = "guide"
            , subtitle = "(coming soon)"
            , links = []
            }
        , el [ centerX, width (fill |> maximum 480) ] <|
            Ui.markdown """
### what can i build with elm-spa?

__This entire site!__ And in this guide we'll build it together, from scratch.
(Step-by-step, with short videos)

<iframe title="elm-spa: welcome to the guide!" src="https://www.youtube.com/embed/OMDMawvANNs" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>


Until that's ready– checkout the [docs](/docs)!
        """
        ]
