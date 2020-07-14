module Generators.Route exposing
    ( generate
    , routeCustomType
    , routeParsers
    , routeSegments
    )

import Path exposing (Path)
import Utils.Generate as Utils


generate : List Path -> String
generate paths =
    String.trim """
module Spa.Generated.Route exposing
    ( Route(..)
    , fromUrl
    , toString
    )

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


{{routeCustomType}}


fromUrl : Url -> Maybe Route
fromUrl =
    Parser.parse routes


routes : Parser (Route -> a) a
routes =
    Parser.oneOf
{{routeParsers}}


toString : Route -> String
toString route =
    let
        segments : List String
        segments =
{{routeSegments}}
    in
    segments
        |> String.join "/"
        |> String.append "/"
"""
        |> String.replace "{{routeCustomType}}" (routeCustomType paths)
        |> String.replace "{{routeParsers}}" (routeParsers paths)
        |> String.replace "{{routeSegments}}" (routeSegments paths)


routeCustomType : List Path -> String
routeCustomType paths =
    Utils.customType
        { name = "Route"
        , variants =
            List.map
                (\path -> Path.toTypeName path ++ Path.optionalParams path)
                paths
        }


routeParsers : List Path -> String
routeParsers paths =
    paths
        |> List.map Path.toParser
        |> Utils.list
        |> Utils.indent 2


routeSegments : List Path -> String
routeSegments paths =
    case paths of
        [] ->
            ""

        _ ->
            Utils.caseExpression
                { variable = "route"
                , cases =
                    paths
                        |> List.map
                            (\path ->
                                ( Path.toTypeName path ++ Path.toParamInputs path
                                , Path.toParamList path
                                )
                            )
                }
                |> Utils.indent 3
