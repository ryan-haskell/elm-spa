module Pages.Docs.Dynamic.Dynamic exposing (Model, Msg, page)

import Components.Sidebar as Sidebar
import Element exposing (..)
import Generated.Docs.Dynamic.Params as Params
import Generated.Routes exposing (Route)
import Http
import Spa.Page
import Ui
import Utils.Markdown as Markdown exposing (Markdown)
import Utils.Spa exposing (Page, PageContext)
import Utils.WebData as WebData exposing (WebData)


page : Page Params.Dynamic Model Msg model msg appMsg
page =
    Spa.Page.element
        { title = \{ model } -> String.join " | " [ viewTitle model, "docs", "elm-spa" ]
        , init = init
        , update = always update
        , subscriptions = always subscriptions
        , view = always view
        }



-- INIT


type alias Model =
    { section : String
    , slug : String
    , markdown : WebData (Markdown Markdown.Frontmatter)
    , route : Route
    }


init : PageContext -> Params.Dynamic -> ( Model, Cmd Msg )
init context { param1, param2 } =
    ( { section = param1
      , slug = param2
      , markdown = WebData.Loading
      , route = context.route
      }
    , Http.get
        { url = "/" ++ String.join "/" [ "content", "docs", param1, param2 ++ ".md" ]
        , expect = WebData.expectMarkdown Loaded
        }
    )



-- UPDATE


type Msg
    = Loaded (WebData (Markdown Markdown.Frontmatter))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Loaded data ->
            ( { model | markdown = data }
            , Cmd.none
            )



-- SUSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Element Msg
view model =
    column [ width fill, spacing 32 ]
        [ Ui.webDataMarkdownArticle model.markdown
        , case model.markdown of
            WebData.Success _ ->
                Sidebar.viewNextArticle model.route

            WebData.Failure _ ->
                Sidebar.viewNextArticle model.route

            _ ->
                text ""
        ]


viewTitle : Model -> String
viewTitle model =
    model.section ++ " " ++ model.slug
