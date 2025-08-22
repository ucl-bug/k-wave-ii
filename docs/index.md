# Welcome to k-Wave-II

This is a first attempt at automated documentation

## Useful `mkdocs` commands

* `mkdocs new [dir-name]` - Create a new project.
* `mkdocs serve` - Start the live-reloading docs server.
* `mkdocs build` - Build the documentation site.
* `mkdocs -h` - Print help message and exit.

## Project layout

    mkdocs.yml    # The configuration file.
    docs/
        index.md  # The documentation homepage.
        ...       # Other markdown pages, images and other files.

## To Do
* Generate html documentation files from the `.m` ones, using the script - see [Building the documentation](about.md)
* Convert them to `.md` with [pandoc](https://pandoc.org/)
* Create proper navigation tree automatically in `mkdocs.yml`