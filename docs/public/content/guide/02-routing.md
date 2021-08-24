# Routing

One of the best features in __elm-spa__ is the automatic routing system! Inspired by popular JS frameworks, the names of your files determine the routes in your application.

Every __elm-spa__ project will have a `src/Pages` folder containing all the pages in your app:

URL | File
--- | ---
`/` | `src/Pages/Home_.elm`
`/people` | `src/Pages/People.elm`
`/people/:name` | `src/Pages/People/Name_.elm`
`/about-us` | `src/Pages/AboutUs.elm`
`/settings/users` | `src/Pages/Settings/Users.elm`

In this section, we'll cover the different kinds of routes you'll find in every __elm-spa__ application.

## The homepage
 
`Home_.elm` is a reserved filename that handles requests to your homepage. The easiest way to add a new homepage is with the [`elm-spa add`](/guide/01-cli#elm-spa-add) covered in the CLI docs:

```terminal
elm-spa add /
```

> `Home.elm` (without the underscore) is seen as a route to `/home`! To handle requests to the homepage, make sure to include the trailing underscore.

## Static routes

Most pages will be __static routes__, meaning the filepath will translate to a single URL.

```terminal
elm-spa add /people
```

This command creates a file called `People.elm` that will be shown when the user visits `/people` in your application.

These are a few more examples of static routes:

URL | File
--- | ---
`/dashboard` | `src/Pages/Dashboard.elm`
`/people` | `src/Pages/People.elm`
`/about-us` | `src/Pages/AboutUs.elm`
`/settings/users` | `src/Pages/Settings/Users.elm`

### Capitalization matters

Notice how the filename `AboutUs.elm` was created from the route `/about-us`?

If we named the path `/aboutus` (without the dash between words) then we'd have a file `Aboutus.elm` (with a lowercase "u").

> In __elm-spa__, we use "kebab-case" rather than "snake_case" as the convention for separating words.

### Nested static routes

You can even have __nested static routes__ within folders:

```terminal
elm-spa add /settings/users
```

This example creates a file at `Settings/Users.elm`, which will handle all requests to `/settings/user`. This pattern continues, supporting nesting things multiple levels deep:

```terminal
elm-spa add /settings/user/contact
```


## Dynamic routes

Sometimes a 1:1 mapping is what you need, but other times, its useful to have a single page that will handles requests to similar URL structures.

A common example is providing a different ID for a blog post, user, or another item in a collection.

```terminal
elm-spa add /people/:name
```

This creates a file at `People/Name_.elm`. In __elm-spa__, we call this a __dynamic route__. It handles requests to any URLs that match `/people/____` and provides the dynamic bit in the `req.params` value passed into your page!

URL | `req.params`
--- | ---
`/people/ryan` | `{ name = "ryan" }`
`/people/alexa` | `{ name = "alexa" }`
`/people/erik` | `{ name = "erik" }`

> The __underscore__ at the end of the filename (`Name_.elm`) indicates that this route is __dynamic__. Without the underscore, it would only handle requests to a single URL: `/people/name`

The name of the `req.params` variable (`name` in this example) is determined by the name of the file! If we named the file `Id_.elm` instead, the dynamic value would be at `req.params.id`.

### Nested dynamic routes

Just like we saw earlier with nested static routes, you can use nested folders to create __nested dynamic routes__!

```terminal
elm-spa add /users/:name/posts/:id
```

This creates a file at `src/Users/Name_/Posts/Id_.elm`, which handles any request that matches `/users/___/posts/___`:

URL | `req.params`
--- | ---
`/users/ryan/posts/123` | `{ name = "ryan", id = "123" }`
`/users/alexa/posts/456` | `{ name = "alexa", id = "456" }`
`/users/erik/posts/789` | `{ name = "erik", id = "789" }`


## Not found page

If a user visits a URL that doesn't have a corresponding page, it will redirect to the `NotFound.elm` page. 

By default, the not found page is generated for you in the `.elm-spa/defaults/Pages` folder. When you are ready to customize your 404 page, move it from the defaults folder into `src/Pages`:

```elm
.elm-spa/
 |- defaults/
     |- Pages/
         |- NotFound.elm

-- move into

src/
 |- Pages/
     |- NotFound.elm
```

Once you have a `NotFound.elm` within your `src/Pages` folder, __elm-spa__ will stop generating the other one, and use your custom 404 file instead.

The technique of moving a file from the `.elm-spa/defaults` folder is known as "ejecting a default file". Throughout the guide, we'll find more examples of files that we might want to move into our `src` folder.

---

__Next up:__ [Pages](./03-pages)
