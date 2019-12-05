---
{ "title": "layouts"
, "description": "shared views for your pages"
}
---

<iframe></iframe>

### what are layouts for?

Take a look at the navbar on this site. That component is used on _every_ page.

When you click a link up there, the __page__ content fades from view, but the
navbar itself stays persistent.

That's because we render our navbar component in the `src/Layout.elm` file.

Layouts enable elm-spa to transition changing pages, without transitioning out
stuff that should persist.

### want another example?

For users viewing this site on a wider screen (like a laptop or desktop),
this docs page has a sidebar on the left side of the page.

If you navigate to `/` or `/guide` using the top navbar, notice that the sidebar
fades smoothly from view?

Now click on a link in the sidebar itself. It doesn't fade away!

Magic? Maybe– but really it's just because that sidebar component is rendered
in the `Layouts/Docs.elm` file.

The next section will show you more details on how we can leverage that to make
the single page app transition in an expected way!
