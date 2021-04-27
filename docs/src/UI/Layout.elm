module UI.Layout exposing
    ( Model, init
    , Msg, update
    , viewDefault, viewDocumentation
    , page, pageFullWidth
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
    , Html.main_ [ Attr.class "page container pad-x-md" ] view
    , footer
    ]


viewFullWidth :
    { model : Model
    , onMsg : Msg -> msg
    , shared : Shared.Model
    , url : Url
    }
    -> List (Html msg)
    -> List (Html msg)
viewFullWidth options view =
    [ navbar options
    , Html.div [ Attr.class "page" ] view
    , footer
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
    , Html.div [ Attr.class "page container pad-md" ]
        [ UI.row.xl [ UI.align.top, UI.padY.lg ]
            [ Html.aside [ Attr.class "only-desktop sticky pad-y-lg aside" ]
                [ UI.Sidebar.viewSidebar
                    { index = options.shared.index
                    , url = options.url
                    }
                ]
            , Html.main_ [ Attr.class "flex" ]
                [ UI.row.lg [ UI.align.top ]
                    [ Html.div [ Attr.class "col flex margin-override" ] view
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
    , footer
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
            let
                href : String
                href =
                    Route.toHref options.route
            in
            Html.a
                [ Attr.class "link"
                , Attr.href href
                , Attr.classList
                    [ ( "bold text-blue"
                      , if href == "/" then
                            href == url.path

                        else
                            String.startsWith href url.path
                      )
                    ]
                ]
                [ Html.text options.text ]
    in
    Html.header [ Attr.class "header pad-y-lg pad-x-md" ]
        [ Html.div [ Attr.class "container" ]
            [ Html.div [ Attr.class "row gap-md spread" ]
                [ Html.div [ Attr.class "row align-center gap-lg" ]
                    [ Html.a [ Attr.class "header__logo", Attr.href "/" ] [ UI.logo ]
                    , Html.nav [ Attr.class "row gap-md hidden-mobile pad-left-xs" ]
                        [ navLink { text = "about", route = Route.Home_ }
                        , navLink { text = "guide", route = Route.Guide }
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
        ]


footer : Html msg
footer =
    Html.div [ Attr.class "footer__zone" ]
        [ Html.footer [ Attr.class "footer container pad-top-xl" ]
            [ Html.div [ Attr.class "row pad-x-md pad-y-lg pad-top-xl spread faded" ]
                [ Html.a [ Attr.href "https://github.com/ryannhg/elm-spa/tree/main/docs", Attr.target "_blank", Attr.class "link hidden-mobile" ] [ Html.text "Site source code" ]
                , Html.span [] [ Html.text "© 2019 – 2021, Ryan Haskell-Glatz" ]
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


pageFullWidth : { view : View Msg } -> Shared.Model -> Request.With params -> Page.With Model Msg
pageFullWidth options shared req =
    Page.sandbox
        { init = init
        , update = update
        , view =
            \model ->
                { title = options.view.title
                , body =
                    viewFullWidth
                        { shared = shared
                        , url = req.url
                        , model = model
                        , onMsg = identity
                        }
                        options.view.body
                }
        }
