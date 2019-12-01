module Pages.Top exposing (Model, Msg, page)

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


page : Page Params.Top Model Msg model msg appMsg
page =
    Spa.Page.static
        { title = always "elm-spa"
        , view = always view
        }



-- VIEW


view : Element Msg
view =
    Ui.sections
        [ Hero.view
            { title = "elm-spa"
            , subtitle = "single page apps made easy"
            , links = [ { label = "get started", url = "/guide" } ]
            }
        , el
            [ width (fill |> maximum 480)
            , centerX
            ]
          <|
            Ui.markdown """
### does elm _need_ a framework?

__nope, not really–__ it's kinda got one built in! so building something like React, VueJS, or Angular wouldn't really make sense.

#### ...but even frameworks need frameworks!

that's why projects like VueJS also have awesome tools like NuxtJS that bring together the best tools in the ecosystem (and a set of shared best practices!)

welcome to __elm-spa__, a framework for Elm!
        """
        ]
