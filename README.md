# Introduction

[![Gem Version](https://badge.fury.io/rb/mbrao.png)](http://badge.fury.io/rb/mbrao)
[![Dependency Status](https://gemnasium.com/ShogunPanda/mbrao.png?travis)](https://gemnasium.com/ShogunPanda/mbrao)
[![Build Status](https://secure.travis-ci.org/ShogunPanda/mbrao.png?branch=master)](https://travis-ci.org/ShogunPanda/mbrao)
[![Code Climate](https://codeclimate.com/github/ShogunPanda/mbrao.png)](https://codeclimate.com/github/ShogunPanda/mbrao)
[![Coverage Status](https://coveralls.io/repos/github/ShogunPanda/mbrao/badge.svg?branch=master)](https://coveralls.io/github/ShogunPanda/mbrao?branch=master)

A content parser and renderer with embedded metadata support.

https://sw.cowtech.it/mbrao

## Usage

mbrao is a content parser and renderer framework for managing posts which have both metadata and content.

First of all a big thanks to the [metadown](https://github.com/steveklabnik/metadown) project which gave me the final idea.

Using mbrao is pretty simple. First of all you have to parse a file with a parsing engine:

```ruby
content = Mbrao::Parser.parse(File.read("/your/content.txt")
```

The default is a plain text reader. This engine reads a text file and parse metadata embedded between `{{metadata}}` and `{{/metadata}}` tag in YAML format.

The method above will return a `Content` object which you can use in your code. This object has builtin support for title, body and tags metadata; all with locale support.

There is also locale filtering. See documentation for more information.

At the end, you can render the content using any engine of your choice:

```ruby
Mbrao::Parser.render(content)
```

The default is a [html-pipeline](https://github.com/jch/html-pipeline) renderer with [kramdown](http://kramdown.rubyforge.org/) support.

## Ruby on Rails support

mbrao has support for integrations with other frameworks. Builtin there is support for Ruby on Rails integration.

By including `gem mbrao` in your `Gemfile` you'll get automatic rendering of `emt` file.

You can customize the rendering engine used by including the `engine` metadata. Also, your controller will get a new `mbrao_content` helper method with the parsed content.

## API Documentation

The API documentation can be found [here](https://sw.cowtech.it/mbrao/docs).

## Contributing to mbrao

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (C) 2013 and above Shogun (shogun@cowtech.it).

Licensed under the MIT license, which can be found at http://www.opensource.org/licenses/mit-license.php.
