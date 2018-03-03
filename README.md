# Spiderman.jl

Linux, OSX: [![Build Status](https://travis-ci.org/dls/Spiderman.jl.svg?branch=master)](https://travis-ci.org/dls/Spiderman.jl)

Windows: [![Build status](https://ci.appveyor.com/api/projects/status/v7nkq6hlq6khutuf?svg=true)](https://ci.appveyor.com/project/dls/spiderman-jl)

[![codecov.io](http://codecov.io/github/dls/Spiderman.jl/coverage.svg?branch=master)](http://codecov.io/github/dls/Spiderman.jl?branch=master)

Your friendly neighborhood webscraping library.

Spiderman provides a
[jQuery](https://jquery.com/)/[Jsoup](http://jsoup.org/) inspired
query language which sits on top of the excellent
[Gumbo.jl](https://github.com/porterjamesj/Gumbo.jl) HTML parsing
library.


# Beta notice

Spiderman.jl is born of my having a bit of NLP fun using julia. It's
essentially a slightly generalized form of the helper functions I
found myself writing.

As such it currently only supports a few of the query types I intend
version one to have. Specifically it only currently supports queries
by tag name, class, and id. Extending it is relatively simple. If you
do, you are strongly urged to add some tests, and send me a pull
request :)

# Examples

Fetch the Wikipedia homepage, parse it, and select the headlines from
the "In the news" section.

```julia
using Spiderman

doc = Spiderman.http_get("http://en.wikipedia.org/")
news_headlines = text(select(css"#mp-itn b a", doc))
```

Get the current top stories from HackerNews (note HN has an API, so
this is a somewhat silly example, but I've stuck with it because HN's
html makes this somewhat more involved).

If you find yourself working with HTML like this, debugging your
queries from IJulia, or on the console is higly recommended.

```julia
doc = Spiderman.http_get("https://news.ycombinator.com/")

scores = select(css".score", doc)
hrefs = parent(select(css".deadmark", doc))

items = []
for i=1:length(scores)
    score = parse(Int, replace(text(scores[i]), " points", ""))
    story_title = text(select(css"a", hrefs[i]))[1]
    story_href = getattr(select(css"a", hrefs[i])[1], "href")
    comment_href = getattr(select(css"a", parent(scores[i]))[end], "href")

    push!(items, (score, story_title, story_href, comment_href))
end
```

The `css"foo"` above works in much the same way as `r"foo"` does for
julia regexes -- by using a macro call, the cost of repeatedly parsing
the css query is removed from your loops and functions.


# Spiderman's HTTP Client

Spiderman's httpclient is a wrapper around
[Requests.jl](https://github.com/JuliaWeb/Requests.jl) (which in
turn is a wrapper around libcurl). It automatically retries up to five
times in the event of a 503 error, or a socket read timeout (both of
which happen with distressing frequency when scraping content from the
open web)

If that's not to your taste there's no need to fret: all of
Spiderman's dom query and manipulation functions are built on top of
Gumbo.jl's datatypes, if you have a preferred http client, or have
already saved the html in question to disk, just use that instead:

```julia
using Gumbo
using Spiderman

doc = parsehtml(html)
news_headlines = text(select(css"#mp-itn b a", doc))
```
