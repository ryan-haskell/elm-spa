module UI.Searchbar exposing (view)

import Domain.Index exposing (Index, Link)
import Html exposing (Html)
import Html.Attributes as Attr
import Html.Events as Events
import Json.Decode as Json


view :
    { index : Index
    , query : String
    , onQueryChange : String -> msg
    }
    -> Html msg
view options =
    Html.node "dropdown-arrow-keys"
        [ Events.on "clearDropdown" (Json.succeed (options.onQueryChange ""))
        ]
        [ Html.label [ Attr.class "search relative z-2", Attr.attribute "aria-label" "Search" ]
            [ Html.input
                [ Attr.id "quick-search"
                , Attr.class "search__input"
                , Attr.type_ "search"
                , Attr.placeholder "Search"
                , Attr.value options.query
                , Events.onInput options.onQueryChange
                ]
                []
            , Html.div [ Attr.class "search__icon icon icon--search" ] []
            , Html.kbd [ Attr.class "search__kbd" ] [ Html.text "/" ]
            , if String.length options.query > 2 then
                case Domain.Index.search options.query options.index of
                    [] ->
                        viewDropdownWindow
                            [ Html.span [ Attr.class "faint pad-md" ] [ Html.text "No matches found." ]
                            ]

                    matches ->
                        viewMatches matches

              else
                Html.text ""
            ]
        ]


viewMatches : List Link -> Html msg
viewMatches matches =
    viewDropdownWindow
        (matches
            |> List.sortBy (\link -> ( link.level, link.label |> String.length ))
            |> List.map
                (\match ->
                    Html.a [ Attr.class "dropdown__link", Attr.href match.url ]
                        [ Html.span [ Attr.class "underline" ] [ Html.map never match.html ]
                        ]
                )
            |> List.take 5
        )


viewDropdownWindow : List (Html msg) -> Html msg
viewDropdownWindow children =
    Html.div [ Attr.class "absolute align-below fill-x pad-top-md" ]
        [ Html.div [ Attr.class "col bg-white shadow border rounded" ]
            children
        ]
