module Tests.Generators.Pages exposing (suite)

import Expect exposing (Expectation)
import Generators.Pages as Pages
import Path exposing (Path)
import Test exposing (..)


paths :
    { empty : List Path
    , single : List Path
    , multiple : List Path
    }
paths =
    { empty = []
    , single =
        [ Path.fromFilepath "Top.elm"
        ]
    , multiple =
        [ Path.fromFilepath "Top.elm"
        , Path.fromFilepath "About.elm"
        , Path.fromFilepath "NotFound.elm"
        , Path.fromFilepath "Posts/Top.elm"
        , Path.fromFilepath "Posts/Id_Int.elm"
        , Path.fromFilepath "Authors/Author_String/Posts/PostId_Int.elm"
        ]
    }


suite : Test
suite =
    describe "Generators.Pages"
        [ describe "pagesImports"
            [ test "returns empty string when no paths" <|
                \_ ->
                    paths.empty
                        |> Pages.pagesImports
                        |> Expect.equal ""
            , test "returns single import for single path" <|
                \_ ->
                    paths.single
                        |> Pages.pagesImports
                        |> Expect.equal "import Pages.Top"
            , test "returns multiple import for multiple path" <|
                \_ ->
                    paths.multiple
                        |> Pages.pagesImports
                        |> Expect.equal (String.trim """
import Pages.Top
import Pages.About
import Pages.NotFound
import Pages.Posts.Top
import Pages.Posts.Id_Int
import Pages.Authors.Author_String.Posts.PostId_Int
""")
            , describe "pagesCustomType"
                [ test "works with single path" <|
                    \_ ->
                        paths.single
                            |> Pages.pagesCustomType "Model"
                            |> Expect.equal "type Model = Top__Model Pages.Top.Model"
                , test "works with multiple paths" <|
                    \_ ->
                        paths.multiple
                            |> Pages.pagesCustomType "Model"
                            |> Expect.equal (String.trim """
type Model
    = Top__Model Pages.Top.Model
    | About__Model Pages.About.Model
    | NotFound__Model Pages.NotFound.Model
    | Posts__Top__Model Pages.Posts.Top.Model
    | Posts__Id_Int__Model Pages.Posts.Id_Int.Model
    | Authors__Author_String__Posts__PostId_Int__Model Pages.Authors.Author_String.Posts.PostId_Int.Model
            """)
                ]
            , describe "pagesUpgradedTypes"
                [ test "works with single path" <|
                    \_ ->
                        paths.single
                            |> Pages.pagesUpgradedTypes
                            |> Expect.equal "    { top : Upgraded Pages.Top.Params Pages.Top.Model Pages.Top.Msg }"
                , test "works with multiple paths" <|
                    \_ ->
                        paths.multiple
                            |> Pages.pagesUpgradedTypes
                            |> Expect.equal """    { top : Upgraded Pages.Top.Params Pages.Top.Model Pages.Top.Msg
    , about : Upgraded Pages.About.Params Pages.About.Model Pages.About.Msg
    , notFound : Upgraded Pages.NotFound.Params Pages.NotFound.Model Pages.NotFound.Msg
    , posts__top : Upgraded Pages.Posts.Top.Params Pages.Posts.Top.Model Pages.Posts.Top.Msg
    , posts__id_int : Upgraded Pages.Posts.Id_Int.Params Pages.Posts.Id_Int.Model Pages.Posts.Id_Int.Msg
    , authors__author_string__posts__postId_int : Upgraded Pages.Authors.Author_String.Posts.PostId_Int.Params Pages.Authors.Author_String.Posts.PostId_Int.Model Pages.Authors.Author_String.Posts.PostId_Int.Msg
    }"""
                ]
            , describe "pagesUpgradedValues"
                [ test "works with single path" <|
                    \_ ->
                        paths.single
                            |> Pages.pagesUpgradedValues
                            |> Expect.equal "    { top = Pages.Top.page |> upgrade Top__Model Top__Msg }"
                , test "works with multiple paths" <|
                    \_ ->
                        paths.multiple
                            |> Pages.pagesUpgradedValues
                            |> Expect.equal """    { top = Pages.Top.page |> upgrade Top__Model Top__Msg
    , about = Pages.About.page |> upgrade About__Model About__Msg
    , notFound = Pages.NotFound.page |> upgrade NotFound__Model NotFound__Msg
    , posts__top = Pages.Posts.Top.page |> upgrade Posts__Top__Model Posts__Top__Msg
    , posts__id_int = Pages.Posts.Id_Int.page |> upgrade Posts__Id_Int__Model Posts__Id_Int__Msg
    , authors__author_string__posts__postId_int = Pages.Authors.Author_String.Posts.PostId_Int.page |> upgrade Authors__Author_String__Posts__PostId_Int__Model Authors__Author_String__Posts__PostId_Int__Msg
    }"""
                ]
            , describe "pagesInit"
                [ test "works with single path" <|
                    \_ ->
                        paths.single
                            |> Pages.pagesInit
                            |> Expect.equal (String.trim """
init : Route -> Shared.Model -> ( Model, Cmd Msg )
init route =
    case route of
        Route.Top ->
            pages.top.init ()
""")
                , test "works with multiple path" <|
                    \_ ->
                        paths.multiple
                            |> Pages.pagesInit
                            |> Expect.equal (String.trim """
init : Route -> Shared.Model -> ( Model, Cmd Msg )
init route =
    case route of
        Route.Top ->
            pages.top.init ()
        
        Route.About ->
            pages.about.init ()
        
        Route.NotFound ->
            pages.notFound.init ()
        
        Route.Posts__Top ->
            pages.posts__top.init ()
        
        Route.Posts__Id_Int params ->
            pages.posts__id_int.init params
        
        Route.Authors__Author_String__Posts__PostId_Int params ->
            pages.authors__author_string__posts__postId_int.init params

""")
                ]
            , describe "pagesUpdate" <|
                [ test "works with single path" <|
                    \_ ->
                        paths.single
                            |> Pages.pagesUpdate
                            |> Expect.equal (String.trim """
update : Msg -> Model -> ( Model, Cmd Msg )
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( Top__Msg msg, Top__Model model ) ->
            pages.top.update msg model
            """)
                , test "works with multiple paths" <|
                    \_ ->
                        paths.multiple
                            |> Pages.pagesUpdate
                            |> Expect.equal (String.trim """
update : Msg -> Model -> ( Model, Cmd Msg )
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( Top__Msg msg, Top__Model model ) ->
            pages.top.update msg model
        
        ( About__Msg msg, About__Model model ) ->
            pages.about.update msg model
        
        ( NotFound__Msg msg, NotFound__Model model ) ->
            pages.notFound.update msg model
        
        ( Posts__Top__Msg msg, Posts__Top__Model model ) ->
            pages.posts__top.update msg model
        
        ( Posts__Id_Int__Msg msg, Posts__Id_Int__Model model ) ->
            pages.posts__id_int.update msg model
        
        ( Authors__Author_String__Posts__PostId_Int__Msg msg, Authors__Author_String__Posts__PostId_Int__Model model ) ->
            pages.authors__author_string__posts__postId_int.update msg model
        
        _ ->
            ( bigModel, Cmd.none )
            """)
                ]
            , describe "pagesBundle" <|
                [ test "works with single path" <|
                    \_ ->
                        paths.single
                            |> Pages.pagesBundle
                            |> Expect.equal (String.trim """
bundle : Model -> Bundle
bundle bigModel =
    case bigModel of
        Top__Model model ->
            pages.top.bundle model
            """)
                , test "works with multiple paths" <|
                    \_ ->
                        paths.multiple
                            |> Pages.pagesBundle
                            |> Expect.equal (String.trim """
bundle : Model -> Bundle
bundle bigModel =
    case bigModel of
        Top__Model model ->
            pages.top.bundle model
        
        About__Model model ->
            pages.about.bundle model
        
        NotFound__Model model ->
            pages.notFound.bundle model
        
        Posts__Top__Model model ->
            pages.posts__top.bundle model
        
        Posts__Id_Int__Model model ->
            pages.posts__id_int.bundle model
        
        Authors__Author_String__Posts__PostId_Int__Model model ->
            pages.authors__author_string__posts__postId_int.bundle model
""")
                ]
            ]
        ]
