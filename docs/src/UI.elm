module UI exposing
    ( Html, none, row, col
    , h1, h2, h3, h4, h5, h6, markdown
    , pad, padX, padY, align
    , link
    , logo, icons, iconLink
    , gutter, hero
    )

{-|

@docs Html, none, el, row, col
@docs h1, h2, h3, h4, h5, h6, markdown
@docs pad, padX, padY, align
@docs link
@docs logo, icons, iconLink

-}

import Html
import Html.Attributes as Attr
import Html.Keyed
import Json.Encode as Json
import Markdown.Block
import Markdown.Html
import Markdown.Parser
import Markdown.Renderer
import UI.Searchbar
import Url exposing (Url)
import Utils.String
import View exposing (View)


type alias Html msg =
    Html.Html msg


none : Html msg
none =
    Html.text ""


link : { text : String, url : String } -> Html msg
link options =
    link_
        { destination = options.url
        , title = Nothing
        }
        [ Html.text options.text
        ]


link_ : { destination : String, title : Maybe String } -> List (Html msg) -> Html msg
link_ options =
    Html.a
        ([ Attr.class "link", Attr.href options.destination ]
            ++ (if String.startsWith "http" options.destination then
                    [ Attr.target "_blank"
                    ]

                else
                    []
               )
        )



-- TYPOGRAPHY


h1 : String -> Html msg
h1 str =
    Html.h1 [ Attr.class "h1" ] [ Html.text str ]


h2 : String -> Html msg
h2 str =
    Html.h2 [ Attr.class "h2" ] [ Html.text str ]


h3 : String -> Html msg
h3 str =
    Html.h3 [ Attr.class "h3" ] [ Html.text str ]


h4 : String -> Html msg
h4 str =
    Html.h4 [ Attr.class "h4" ] [ Html.text str ]


h5 : String -> Html msg
h5 str =
    Html.h5 [ Attr.class "h5" ] [ Html.text str ]


h6 : String -> Html msg
h6 str =
    Html.h6 [ Attr.class "h6" ] [ Html.text str ]


paragraphs : List String -> Html msg
paragraphs strs =
    strs
        |> List.map (Html.text >> List.singleton >> Html.p [ Attr.class "p" ])
        |> Html.div [ Attr.class "col gap-md" ]


gutter : Html msg
gutter =
    Html.div [ Attr.style "height" "25vh" ] []


markdown : { withHeaderLinks : Bool } -> String -> Html msg
markdown options str =
    let
        default =
            Markdown.Renderer.defaultHtmlRenderer

        renderer =
            { default
                | heading =
                    \props ->
                        let
                            id : String
                            id =
                                Utils.String.toId props.rawText

                            content : List (Html msg)
                            content =
                                contentWith ("#" ++ id)

                            contentWith : String -> List (Html msg)
                            contentWith url =
                                if options.withHeaderLinks then
                                    [ Html.a [ Attr.class "markdown__link", Attr.href url ] props.children ]

                                else
                                    props.children
                        in
                        case props.level of
                            Markdown.Block.H1 ->
                                Html.h1 [ Attr.id id, Attr.class "h1" ] (contentWith "")

                            Markdown.Block.H2 ->
                                Html.h2 [ Attr.id id, Attr.class "h2" ] content

                            Markdown.Block.H3 ->
                                Html.h3 [ Attr.id id, Attr.class "h3" ] content

                            Markdown.Block.H4 ->
                                Html.h4 [ Attr.id id, Attr.class "h4" ] content

                            Markdown.Block.H5 ->
                                Html.h5 [ Attr.id id, Attr.class "h5" ] content

                            Markdown.Block.H6 ->
                                Html.h6 [ Attr.class "h6" ] content
                , paragraph = Html.p [ Attr.class "p" ]
                , table = \children -> Html.div [ Attr.class "table" ] [ Html.table [] children ]
                , link = link_
                , codeBlock =
                    \{ body, language } ->
                        if language == Just "elm" then
                            Html.Keyed.node "div"
                                []
                                [ ( body
                                  , Html.node "highlight-js"
                                        [ Attr.property "body" (Json.string body)
                                        , Attr.property "language" (Json.string "elm")
                                        ]
                                        []
                                  )
                                ]

                        else
                            Html.pre [ Attr.class ("language-" ++ (language |> Maybe.withDefault "none")) ]
                                [ Html.code [ Attr.class ("language-" ++ (language |> Maybe.withDefault "none")) ]
                                    [ Html.text body ]
                                ]
            }
    in
    Markdown.Parser.parse str
        |> Result.mapError (\_ -> "Failed to parse.")
        |> Result.andThen (Markdown.Renderer.render renderer)
        |> Result.withDefault []
        |> Html.div [ Attr.class "markdown" ]



-- LAYOUT


row :
    { xs : List (Attribute msg) -> List (Html msg) -> Html msg
    , sm : List (Attribute msg) -> List (Html msg) -> Html msg
    , md : List (Attribute msg) -> List (Html msg) -> Html msg
    , lg : List (Attribute msg) -> List (Html msg) -> Html msg
    , xl : List (Attribute msg) -> List (Html msg) -> Html msg
    }
row =
    { xs = \attrs -> Html.div (Attr.class "row gap-xs" :: attrs)
    , sm = \attrs -> Html.div (Attr.class "row gap-sm" :: attrs)
    , md = \attrs -> Html.div (Attr.class "row gap-md" :: attrs)
    , lg = \attrs -> Html.div (Attr.class "row gap-lg" :: attrs)
    , xl = \attrs -> Html.div (Attr.class "row gap-xl" :: attrs)
    }


col :
    { xs : List (Attribute msg) -> List (Html msg) -> Html msg
    , sm : List (Attribute msg) -> List (Html msg) -> Html msg
    , md : List (Attribute msg) -> List (Html msg) -> Html msg
    , lg : List (Attribute msg) -> List (Html msg) -> Html msg
    , xl : List (Attribute msg) -> List (Html msg) -> Html msg
    }
col =
    { xs = \attrs -> Html.div (Attr.class "col gap-xs" :: attrs)
    , sm = \attrs -> Html.div (Attr.class "col gap-sm" :: attrs)
    , md = \attrs -> Html.div (Attr.class "col gap-md" :: attrs)
    , lg = \attrs -> Html.div (Attr.class "col gap-lg" :: attrs)
    , xl = \attrs -> Html.div (Attr.class "col gap-xl" :: attrs)
    }



-- ATTRS


type alias Attribute msg =
    Html.Attribute msg


pad :
    { xs : Attribute msg
    , sm : Attribute msg
    , md : Attribute msg
    , lg : Attribute msg
    , xl : Attribute msg
    }
pad =
    { xs = Attr.class "pad-xs"
    , sm = Attr.class "pad-sm"
    , md = Attr.class "pad-md"
    , lg = Attr.class "pad-lg"
    , xl = Attr.class "pad-xl"
    }


padX :
    { xs : Attribute msg
    , sm : Attribute msg
    , md : Attribute msg
    , lg : Attribute msg
    , xl : Attribute msg
    }
padX =
    { xs = Attr.class "pad-x-xs"
    , sm = Attr.class "pad-x-sm"
    , md = Attr.class "pad-x-md"
    , lg = Attr.class "pad-x-lg"
    , xl = Attr.class "pad-x-xl"
    }


padY :
    { xs : Attribute msg
    , sm : Attribute msg
    , md : Attribute msg
    , lg : Attribute msg
    , xl : Attribute msg
    }
padY =
    { xs = Attr.class "pad-y-xs"
    , sm = Attr.class "pad-y-sm"
    , md = Attr.class "pad-y-md"
    , lg = Attr.class "pad-y-lg"
    , xl = Attr.class "pad-y-xl"
    }


align :
    { center : Attribute msg
    , top : Attribute msg
    , left : Attribute msg
    , right : Attribute msg
    , bottom : Attribute msg
    , centerX : Attribute msg
    , centerY : Attribute msg
    }
align =
    { center = Attr.class "align-center"
    , top = Attr.class "align-top"
    , left = Attr.class "align-left"
    , right = Attr.class "align-right"
    , bottom = Attr.class "align-bottom"
    , centerX = Attr.class "align-center-x"
    , centerY = Attr.class "align-center-y"
    }



-- HERO


hero : { title : String, description : String } -> Html msg
hero options =
    Html.div [ Attr.class "pad-y-xl" ]
        [ Html.div [ Attr.class "row gap-md pad-y-xl" ]
            [ Html.div [ Attr.class "logo" ] []
            , Html.div [ Attr.class "col gap-xs" ]
                [ h1 options.title
                , Html.div [ Attr.class "text-500" ] [ Html.h2 [ Attr.class "h5" ] [ Html.text options.description ] ]
                ]
            ]
        ]



-- LOGO


logo : Html msg
logo =
    Html.div [ Attr.class "row gap-sm" ]
        [ Html.div [ Attr.class "logo logo--small" ] []
        , Html.div [ Attr.class "logo__text" ] [ Html.text "elm-spa" ]
        ]



-- ICONS


type Icon
    = Icon String


icons :
    { github : Icon
    , npm : Icon
    , elm : Icon
    }
icons =
    { github = Icon "fa-github"
    , npm = Icon "fa-npm"
    , elm = Icon "fa-elm"
    }


iconLink : { text : String, icon : Icon, url : String } -> Html msg
iconLink options =
    let
        (Icon class) =
            options.icon
    in
    Html.a [ Attr.href options.url, Attr.target "_blank", Attr.attribute "aria-label" options.text ]
        [ Html.i [ Attr.class ("link__icon fab " ++ class) ] []
        ]
