module Generated.Routes exposing
    ( Route
    , parsers
    , routes
    , toPath
    )

import Generated.Docs.Route
import Generated.Guide.Dynamic.Dynamic.Route
import Generated.Guide.Dynamic.Faq.Route
import Generated.Guide.Dynamic.Route
import Generated.Guide.Route
import Generated.Route
import Url.Parser as Parser exposing ((</>), Parser, map, s, string, top)



-- ALIASES


type alias Route =
    Generated.Route.Route


toPath : Route -> String
toPath =
    Generated.Route.toPath



-- ROUTES


type alias Routes =
    { top : Route
    , docs : Route
    , guide : Route
    , notFound : Route
    , signIn : Route
    , guide_elm : Route
    , guide_elmSpa : Route
    , guide_programming : Route
    , guide_dynamic_intro : String -> Route
    , guide_dynamic_other : String -> Route
    , guide_dynamic_faq_top : String -> Route
    , guide_dynamic_dynamic_top : String -> String -> Route
    , docs_static : Route
    , docs_dynamic : String -> Route
    }


routes : Routes
routes =
    { top =
        Generated.Route.Top {}
    , docs =
        Generated.Route.Docs {}
    , guide =
        Generated.Route.Guide {}
    , notFound =
        Generated.Route.NotFound {}
    , signIn =
        Generated.Route.SignIn {}
    , guide_elm =
        Generated.Route.Guide_Folder <|
            Generated.Guide.Route.Elm {}
    , guide_elmSpa =
        Generated.Route.Guide_Folder <|
            Generated.Guide.Route.ElmSpa {}
    , guide_programming =
        Generated.Route.Guide_Folder <|
            Generated.Guide.Route.Programming {}
    , guide_dynamic_intro =
        \param1 ->
            Generated.Route.Guide_Folder <|
                Generated.Guide.Route.Dynamic_Folder param1 <|
                    Generated.Guide.Dynamic.Route.Intro { param1 = param1 }
    , guide_dynamic_other =
        \param1 ->
            Generated.Route.Guide_Folder <|
                Generated.Guide.Route.Dynamic_Folder param1 <|
                    Generated.Guide.Dynamic.Route.Other { param1 = param1 }
    , guide_dynamic_faq_top =
        \param1 ->
            Generated.Route.Guide_Folder <|
                Generated.Guide.Route.Dynamic_Folder param1 <|
                    Generated.Guide.Dynamic.Route.Faq_Folder <|
                        Generated.Guide.Dynamic.Faq.Route.Top { param1 = param1 }
    , guide_dynamic_dynamic_top =
        \param1 param2 ->
            Generated.Route.Guide_Folder <|
                Generated.Guide.Route.Dynamic_Folder param1 <|
                    Generated.Guide.Dynamic.Route.Dynamic_Folder param2 <|
                        Generated.Guide.Dynamic.Dynamic.Route.Top { param1 = param1, param2 = param2 }
    , docs_static =
        Generated.Route.Docs_Folder <|
            Generated.Docs.Route.Static {}
    , docs_dynamic =
        \param1 ->
            Generated.Route.Docs_Folder <|
                Generated.Docs.Route.Dynamic param1 { param1 = param1 }
    }


parsers : List (Parser (Route -> a) a)
parsers =
    [ map routes.top
        top
    , map routes.docs
        (s "docs")
    , map routes.guide
        (s "guide")
    , map routes.notFound
        (s "not-found")
    , map routes.signIn
        (s "sign-in")
    , map routes.guide_elm
        (s "guide" </> s "elm")
    , map routes.guide_elmSpa
        (s "guide" </> s "elm-spa")
    , map routes.guide_programming
        (s "guide" </> s "programming")
    , map routes.guide_dynamic_intro
        (s "guide" </> string </> s "intro")
    , map routes.guide_dynamic_other
        (s "guide" </> string </> s "other")
    , map routes.guide_dynamic_faq_top
        (s "guide" </> string </> s "faq" </> top)
    , map routes.guide_dynamic_dynamic_top
        (s "guide" </> string </> string </> top)
    , map routes.docs_static
        (s "docs" </> s "static")
    , map routes.docs_dynamic
        (s "docs" </> string)
    ]
