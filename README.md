# CodeSnippet

[![Ruby](https://github.com/andrewbigger/code_snippet/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/andrewbigger/code_snippet/actions/workflows/build.yml)

A code snippet handling tool that makes it easy to quickly access chunks of code.

## Installation

Install the gem into your system:

```bash
gem install code_snippet
```

## Usage

### Before you begin

Before you use snippet, you need to set the `SNIPPET_DIR` environment variable to a path that contains your snippets:

```bash
export SNIPPET_DIR="/Users/me/Code/snippets"
```

### Creating snippets

Snippets are just text files with the extension of the target language. For example, `for_i.go` might ontain a for loop.

The code does not need to compile or be able to be interpreted for it to be displayed by snippet, it should be content that's easy to paste into the project you're currently working on.

### Listing and Viewing Snippets

Once you have a set of snippets, run `snippet list` to show a list of all your snippets:

```bash
$ snippet list

NAME                          LANG
for_i                         .go 
table_test                    .go
```

You can then show a snippet by executing `snippet show <name>`:

```bash
$ snippet show for_i

for 1 := 1; i < 10; i++ {
  // do something
}
```

You can copy the snippet straight to the clipboard by adding the `--copy` to the end of the command.

## Tests and Quality

Tests cover this project and are written in RSpec. You'll find them in the spec folder.

```bash
bundle exec rspec spec
```

Tests and quality tasks are included in the default rake task which can be run thus:

```bash
bundle exec rake
```

## Contributing

See CONTRIBUTING.md for more information

## Licence

This gem is covered by the terms of the MIT licence. See LICENCE for more information
