# gfrör.li Webapp

[![CI][ci-badge]][ci]

Web application for the water sensor API, written in
[Elm](http://elm-lang.org/).

## Requirements

You need NodeJS 22. Elm will be installed through npm.

If you aren't familiar with Elm yet, you should probably read [the
tutorial](https://guide.elm-lang.org/). When you're done with that,
here's [another tutorial](https://www.elm-tutorial.org/).

If you use `nvm`, add an override for the required NodeJS version:

    nvm install
    nvm use

To install all dependencies:

    make setup

Next, set up the required env vars:

    echo "API_TOKEN='...'" >> .env

## Building

To build the application, just type

    make dist

The output will be written to the `dist/` directory.

## Development

To start the dev server:

    make run

Now visit [localhost:8000](http://localhost:8000/) in your browser
to see the application.

## Tests

To run the tests:

    make test

## Changing Code

The entry point of the application is in `src/elm/Main.elm`. The application is
injected into a HTML page in `src/static/index.html.hbs`. The non-Elm scripting
is done in `src/static/index.js`, and bridged to Elm using the [port
system](https://guide.elm-lang.org/interop/javascript.html).

Contributions are welcome. If you need any guidance, feel free to create an
issue on Github or [join our Mattermost channel ~gfrorli on
chat.coredump.ch](https://chat.coredump.ch/coredump/channels/gfrorli)!

Before committing, make sure to reformat your code with elm-format. You can do
so using your IDE, or with `make format`.

## License

Copyright © 2017–2025 Coredump Hackerspace.

Licensed under the AGPLv3 or later, see `LICENSE.md`.


<!-- Badges -->
[ci]: https://github.com/gfroerli/web/actions?query=workflow%3ACI
[ci-badge]: https://img.shields.io/github/actions/workflow/status/gfroerli/web/ci.yml?branch=main
