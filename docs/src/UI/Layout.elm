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

import Gen.Route as Route exposing (Route)
import Html exposing (Html)
import Html.Attributes as Attr
import Page exposing (Page)
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
    , Html.div [ Attr.class "container pad-md" ]
        [ UI.row.xl [ UI.align.top, UI.padY.lg ]
            [ Html.aside [ Attr.class "only-desktop sticky pad-y-lg aside" ]
                [ UI.Sidebar.viewSidebar
                    { index = options.shared.index
                    , url = options.url
                    }
                ]
            , Html.main_ [ Attr.class "flex" ]
                [ UI.row.lg [ UI.align.top ]
                    [ Html.div [ Attr.class "col flex" ] view
                    , Html.div [ Attr.class "hidden-mobile sticky pad-y-lg table-of-contents" ]
                        [ UI.Sidebar.viewTableOfContents
                            { content = markdownContent
                            , url = options.url
                            }
                        ]
                    ]
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
        navLink : { text : String, route : Route } -> Html msg
        navLink options =
            Html.a
                [ Attr.class "link"
                , Attr.href (Route.toHref options.route)
                , Attr.classList [ ( "bold text-blue", String.startsWith (Route.toHref options.route) url.path ) ]
                ]
                [ Html.text options.text ]
    in
    Html.header [ Attr.class "container pad-md" ]
        [ Html.div [ Attr.class "row gap-md spread" ]
            [ Html.div [ Attr.class "row align-center gap-md" ]
                [ Html.a [ Attr.href "/" ] [ UI.logo ]
                , Html.nav [ Attr.class "row gap-md hidden-mobile pad-left-xs" ]
                    [ navLink { text = "docs", route = Route.Docs }
                    , navLink { text = "guides  ", route = Route.Guides }
                    , navLink { text = "examples", route = Route.Examples }
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


page : { view : View Msg } -> Shared.Model -> Request.With params -> Page.With Model Msg
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
