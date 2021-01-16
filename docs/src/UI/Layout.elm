module UI.Layout exposing
    ( Model, init
    , Msg, update
    , viewDefault, viewDocumentation
    , page
    )

{-|

@docs Model, init
@docs Msg, update
@docs viewDefault, viewDocumentation

-}

import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Page exposing (Page, shared)
import Request exposing (Request)
import Shared
import UI
import UI.Searchbar
import UI.Sidebar
import Url exposing (Url)
import View exposing (View)


type alias Model =
    { query : String
    }


init : Model
init =
    { query = ""
    }


type Msg
    = OnQueryChange String


update : Msg -> Model -> Model
update msg model =
    case msg of
        OnQueryChange query ->
            { model | query = query }


viewDefault :
    { model : Model
    , onMsg : Msg -> msg
    , shared : Shared.Model
    , url : Url
    }
    -> List (Html msg)
    -> List (Html msg)
viewDefault options view =
    [ navbar options
    , Html.main_ [ Attr.class "container pad-x-md" ] view
    ]


viewDocumentation :
    { model : Model
    , onMsg : Msg -> msg
    , shared : Shared.Model
    , url : Url
    }
    -> String
    -> List (Html msg)
    -> List (Html msg)
viewDocumentation options markdownContent view =
    [ navbar options
    , Html.div [ Attr.class "container pad-lg" ]
        [ UI.row.lg [ UI.align.top, UI.padY.lg ]
            [ Html.aside [ Attr.class "only-desktop sticky pad-y-lg", Attr.style "width" "13em" ]
                [ UI.Sidebar.viewSidebar
                    { index = options.shared.index
                    , url = options.url
                    }
                ]
            , Html.main_ [ Attr.class "col flex" ] view
            , Html.div [ Attr.class "hidden-mobile sticky pad-y-lg", Attr.style "width" "16em" ]
                [ UI.Sidebar.viewTableOfContents
                    { content = markdownContent
                    , url = options.url
                    }
                ]
            ]
        ]
    ]


navbar :
    { model : Model
    , onMsg : Msg -> msg
    , shared : Shared.Model
    , url : Url
    }
    -> Html msg
navbar { onMsg, model, shared, url } =
    let
        navLink : { text : String, url : String } -> Html msg
        navLink options =
            Html.a
                [ Attr.class "link"
                , Attr.href options.url
                , Attr.classList [ ( "bold text-blue", String.startsWith options.url url.path ) ]
                ]
                [ Html.text options.text ]
    in
    Html.header [ Attr.class "container pad-md" ]
        [ Html.div [ Attr.class "row gap-md spread" ]
            [ Html.div [ Attr.class "row align-center gap-md" ]
                [ Html.a [ Attr.href "/" ] [ UI.logo ]
                , Html.nav [ Attr.class "row gap-md hidden-mobile pad-left-xs" ]
                    [ navLink { text = "guide", url = "/guide" }
                    , navLink { text = "docs", url = "/docs" }
                    , navLink { text = "examples", url = "/examples" }
                    ]
                ]
            , Html.div [ Attr.class "row gap-md spread" ]
                [ Html.nav [ Attr.class "row gap-md hidden-mobile" ]
                    [ UI.iconLink { text = "GitHub Repo", icon = UI.icons.github, url = "https://github.com/ryannhg/elm-spa" }
                    , UI.iconLink { text = "NPM Package", icon = UI.icons.npm, url = "https://npmjs.org/elm-spa" }
                    , UI.iconLink { text = "Elm Package", icon = UI.icons.elm, url = "https://package.elm-lang.org/packages/ryannhg/elm-spa/latest" }
                    ]
                , UI.Searchbar.view
                    { index = shared.index
                    , query = model.query
                    , onQueryChange = onMsg << OnQueryChange
                    }
                ]
            ]
        ]



-- PAGE


page : { view : View Msg } -> Shared.Model -> Request params -> Page Model Msg
page options shared req =
    Page.sandbox
        { init = init
        , update = update
        , view =
            \model ->
                { title = options.view.title
                , body =
                    viewDefault
                        { shared = shared
                        , url = req.url
                        , model = model
                        , onMsg = identity
                        }
                        options.view.body
                }
        }
