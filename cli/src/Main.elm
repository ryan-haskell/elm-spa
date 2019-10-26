port module Main exposing (main)

import Item exposing (Item)
import Json.Decode as D exposing (Decoder)
import Templates.TopLevelPages
import Templates.TopLevelRoute


port toJs : List NewFile -> Cmd msg


type alias NewFile =
    { filepathSegments : List String
    , contents : String
    }



-- PROGRAM


main : Program D.Value () msg
main =
    Platform.worker
        { init = \json -> ( (), toJs <| parse json )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = always Sub.none
        }


parse : D.Value -> List NewFile
parse =
    D.decodeValue decoder >> Result.withDefault []



-- DECODER


decoder : Decoder (List NewFile)
decoder =
    D.list Item.decoder
        |> D.map fromData


fromData : List Item -> List NewFile
fromData items =
    List.concat
        [ [ topLevelRoute items ]
        , [ topLevelPages items ]
        , nestedRoutes items
        , nestedPages items
        ]


topLevelPages : List Item -> NewFile
topLevelPages items =
    { filepathSegments = [ "Generated", "Pages.elm" ]
    , contents = Templates.TopLevelPages.contents items
    }


topLevelRoute : List Item -> NewFile
topLevelRoute items =
    { filepathSegments = [ "Generated", "Route.elm" ]
    , contents = Templates.TopLevelRoute.contents items
    }


nestedRoutes : List Item -> List NewFile
nestedRoutes _ =
    []


nestedPages : List Item -> List NewFile
nestedPages _ =
    []
