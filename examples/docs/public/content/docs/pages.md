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
