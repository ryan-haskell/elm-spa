---
{ "title" : "Page.element"
, "description": "pages with state and side-effects."
}
---

<iframe></iframe>

### pages with state and side-effects.

Okay so I lied about `/docs/pages/static` using [Page.static](./static). We actually
need to make an HTTP request on `init` to fetch content from [this markdown file](/content/docs/pages/element.md) that you're reading.

So for that reason, we're going to upgrade to a `Page.element`– which is able to
send `Cmd Msg` and do cool things like making web requests.

Let's use `elm-spa add` to create an element page like this:

```bash
npx elm-spa add element Docs.Dynamic.Dynamic
```

Since we are using `Dynamic`, this route will match paths like these:

- `/docs/pages/static`
- `/docs/pages/element`
- `/docs/elm-spa/add`

For that first example, our `init` function receives `Params` that look like this:

```elm
{ param1 = "pages"
, param2 = "static"
}
```

(You can read more about this in the [routing section](/docs/routing/naming))