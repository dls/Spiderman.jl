# verify that our README.md examples are in working order

doc = Spiderman.http_get("http://en.wikipedia.org/")
news_headlines = text(select(css"#mp-itn b a", doc))

# most of the value in this test is the above code running...
# but it's still nice to know the query still works.
@test length(news_headlines) > 1



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

@test length(items) > 2