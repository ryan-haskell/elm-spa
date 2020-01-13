---
{ "title": "pages"
, "description": "views rendered at some url."
}
---

<iframe></iframe>

### how routing works

With elm-spa, creating a file in `src/Pages` automatically takes care of routing
and plugs your new page where it belongs in your layouts and single page app.

If you have a folder structure like this:

```elm
src/
  Pages/
    Top.elm
    Guide.elm
    NotFound.elm
    Docs/
      Dynamic.elm
```

Will generate routes like these:

Path | Elm file
:-- | :--
`/` | `src/Pages/Top.elm`
`/guide` | `src/Pages/Guide.elm`
`/not-found` | `src/Pages/NotFound.elm`
`/docs/pages` | `src/Pages/Docs/Dynamic.elm`
`/docs/elm-spa` | `src/Pages/Docs/Dynamic.elm`
`/docs/deploying` | `src/Pages/Docs/Dynamic.elm`

#### naming pages

The names of your files correspond to the routes in your app.

Creating an `Example.elm` file tells elm-spa to generate the route `/example`

You can nest files in folders like `SomeFolder/Example.elm` and that will
result in `/some-folder/example`.

Note that capitalization in module names creates a dash (`-`) in between the
URL.

#### top-level routes

To declare top-level routes (like for the homepage), elm-spa reserves the name 
`Top` to allow you to do things like this:

Path | Elm file
:-- | :--
`/` | `src/Pages/Top.elm`
`/guide` | `src/Pages/Guide/Top.elm`
`/top` | `src/Pages/Top/Top.elm`

Only the filename is reserved, so you can create `/top` if you like!

#### dynamic routes

If you want to use the same page to match different routes, you can use
`Dynamic` as the file or folder name.

The dynamic parameters will be available to your `init` function.

Here are some examples:


##### src/Pages/Dynamic.elm

Path | Params
:-- | :--
`/foo` | `{ param1 = "foo" }`
`/bar` | `{ param1 = "bar" }`
`/123` | `{ param1 = "123" }`

##### src/Pages/Docs/Dynamic.elm

Path | Params
:-- | :--
`/docs/foo` | `{ param1 = "foo" }`
`/docs/bar` | `{ param1 = "bar" }`
`/docs/123` | `{ param1 = "123" }`

##### src/Pages/Dynamic/Dynamic.elm

Path | Params
:-- | :--
`/hello/foo` | `{ param1 = "hello", param2 = "foo" }`
`/from/bar` | `{ param1 = "from", param2 = "bar" }`
`/anything/123` | `{ param1 = "anything", param2 = "123" }`


### choosing the right page

the following sections show off the 4 types of pages you can
create with elm-spa!