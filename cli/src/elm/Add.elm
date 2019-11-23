module Add exposing
    ( PageType
    , generate
    , modulePathDecoder
    , pageTypeDecoder
    )

import Json.Decode as D exposing (Decoder)
import Templates.Component
import Templates.Element
import Templates.Sandbox
import Templates.Static


type PageType
    = Static
    | Sandbox
    | Element
    | Component


pageTypeDecoder : Decoder PageType
pageTypeDecoder =
    D.string
        |> D.andThen
            (\pageType ->
                case pageType of
                    "static" ->
                        D.succeed Static

                    "sandbox" ->
                        D.succeed Sandbox

                    "element" ->
                        D.succeed Element

                    "component" ->
                        D.succeed Component

                    _ ->
                        D.fail <| "Did not recognize page type: " ++ pageType
            )


modulePathDecoder : Decoder (List String)
modulePathDecoder =
    let
        isValidModuleName : String -> Bool
        isValidModuleName name =
            String.split "." name
                |> List.all
                    (\str ->
                        case String.toList str of
                            [] ->
                                False

                            first :: rest ->
                                Char.isUpper first && List.all Char.isAlpha rest
                    )
    in
    D.string
        |> D.andThen
            (\name ->
                if isValidModuleName name then
                    D.succeed (String.split "." name)

                else
                    D.fail "That module name isn't valid."
            )


generate : PageType -> { modulePath : List String, ui : String } -> String
generate pageType =
    case pageType of
        Static ->
            Templates.Static.contents

        Sandbox ->
            Templates.Sandbox.contents

        Element ->
            Templates.Element.contents

        Component ->
            Templates.Component.contents
