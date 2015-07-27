# API Documentation

The API docs are currently assembled from the markdown files found in the `api_docs` directory. You should edit
these files to reflect changes to the API, but this is not enough to make the changes visible on the website.

## The API Blueprint Format

The documentation for our API methods is written in a special type of Markdown called [API Blueprint](https://apiblueprint.org/), that has some very specific rules about formatting. If it doesn't compile, it should tell you as part of the Rake generation task, but it can be a pain to make sure your code snippets are indented 8 spaces and other such rules.

This markdown is turned into straight-up HTML by a program called Aglio.

## Installing Aglio

Aglio is a Node.js tool that takes API Blueprint files as inputs and renders out HTML. Currently our template and documentation are incompatible with version 2.0 of Aglio. So, to build this we need to install an older version (1.18 is fine). It will print out some warnings about deprecations, but it will still work.

```
npm install -g aglio@1.18
```

## Regenerating the Documentation

The documentation can be rebuilt by running the command `rake api_docs:regenerate`. This does several steps as part of its execution.

1. First it deletes the existing documentation HTML
2. It concatenates the separate `.apib` files in the `api_docs/` directory into a single file in `public`
3. It then runs Aglio with this file as an input and using a custom Jade template to render out to a file `/app/views/marketing/_developer.html.erb`
4. This is the file rendered when the user visits the `/developer` route in MyUSA.