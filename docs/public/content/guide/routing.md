# Routing

One of the best reasons to use __elm-spa__ is the automatic routing! Inspired by popular JS frameworks like _NuxtJS_, we use file names to determine routes in your application.

Every __elm-spa__ project will have a `Pages` folder with all the pages in the application.

URL | File
--- | ---
`/` | `src/Pages/Home_.elm`
`/people` | `src/Pages/People.elm`
`/people/:name` | `src/Pages/People/Name_.elm`
`/about-us` | `src/Pages/AboutUs.elm`
`/settings/users` | `src/Pages/Settings/Users.elm`

In this section, we'll cover the 3 kinds of routes you can find in an __elm-spa__ application.

## The homepage

The `src/Pages/Home_.elm` file is a reserved page that handles requests to `/`. The easiest way to make a new homepage is with the [`add` command](/guide/cli#adding-a-homepage) covered in the CLI section:

```terminal
elm-spa add /
```

__Note:__ Without the trailing underscore, __elm-spa__ will treat `Home.elm` as a route to `/home`! This is called a "static route", and will be covered at the end of this sentence.

## Static routes

Most pages will be __static routes__, meaning the filepath will translate to a single URL.

```terminal
elm-spa add /people
```

This command creates a page at `src/Pages/People.elm` that will be shown when the user visits `/people` in your app!

These are more examples of static routes:

URL | File
--- | ---
`/dashboard` | `src/Pages/Dashboard.elm`
`/people` | `src/Pages/People.elm`
`/about-us` | `src/Pages/AboutUs.elm`
`/settings/users` | `src/Pages/Settings/Users.elm`

### Nested static routes

You can use folders to have __nested static routes__:

```terminal
elm-spa add /settings/users
```

This example creates a file at `src/Pages/Settings/Users.elm`, which will handle all requests to `/settings/user`. You can nest things multiple levels by creating even more nested folders:

```terminal
elm-spa add /settings/user/contact
```


## Dynamic routes

Sometimes a 1:1 mapping is what you need, but other times, its useful to have a route that handles requests to many items.

```terminal
elm-spa add /people/:name
```

This will create a file at `src/Pages/People/Name_.elm`. In __elm-spa__, this is called a __dynamic route__. It will handle requests to any URLs that match `/people/____` and provide the dynamic part in the parameters.

URL | Params
--- | ---
`/people/ryan` | `{ name = "ryan" }`
`/people/alexa` | `{ name = "alexa" }`
`/people/erik` | `{ name = "erik" }`

The __trailing underscore__ at the end of the filename (`Name_.elm`) indicates that this route is __dynamic__. Without the underscore, it would only handle requests to `/people/name`

The name of the route parameter variable (`name` in this example) is determined by the name of the file! If we named the file `Id_.elm`, the dynamic value would be available at `params.id` instead.

Every page gets access to these dynamic parameters, via the [`Request params`](/guide/pages#requests) value passed in. We'll cover that in the next section!

### Nested dynamic routes

Just like we saw with __nested static routes__, you can use nested folders to create nested dynamic routes!

```terminal
elm-spa add /users/:name/posts/:id
```

This creates a file at `src/Users/Name_/Posts/Id_.elm`

URL | Params
--- | ---
`/users/ryan/posts/123` | `{ name = "ryan", id = "123" }`
`/users/alexa/posts/456` | `{ name = "alexa", id = "456" }`
`/users/erik/posts/789` | `{ name = "erik", id = "789" }`

It will handle any request to `/users/___/posts/___`


## Not found page

If a user visits a URL that doesn't have a corresponding page, it will redirect to the `NotFound.elm` page. This is generated for you by default in the `.elm-spa/defaults/Pages` folder. When you are ready to customize it, move it into `src/Pages` and customize it like you would any other page!

In __elm-spa__, this technique is called "ejecting" a default file. Throughout the guide, we'll find more default files that we might want to control in our project.