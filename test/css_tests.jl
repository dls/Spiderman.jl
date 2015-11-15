# manually
@test compile_css("a") == Spiderman.IsTag("a")
@test compile_css(".a") == Spiderman.HasClass(r"\ba\b")
@test compile_css("#a") == Spiderman.HasId("a")
@test compile_css("a#b.c") == Spiderman.MatchGroup([Spiderman.IsTag("a"), Spiderman.HasId("b"), Spiderman.HasClass("c")])
@test compile_css("a b") == [Spiderman.IsTag("a"), Spiderman.IsTag("b")]

# macro'd
@test css"a" == Spiderman.IsTag("a")
@test css".a" == Spiderman.HasClass(r"\ba\b")
@test css"#a" == Spiderman.HasId("a")
@test css"a#b.c" == Spiderman.MatchGroup([Spiderman.IsTag("a"), Spiderman.HasId("b"), Spiderman.HasClass("c")])
@test css"a b" == [Spiderman.IsTag("a"), Spiderman.IsTag("b")]


# testing data
basic = parsehtml("""
<html>
<body>
  <div>
    <p id='one' class='a b'></p> <a class='b c'></a> <p id='two' class='c d'></p>
  </div>
  <div class='d2'>
    <span class='d'></span>
    <span class='e'>Some text here</span>
    <span>and more here</span>
  </div>
</body>
</html>
""")


# one-level matches
@test select(css"#one", basic) == [t("<p id='one' class='a b'></p>")]
@test select(css"#two", basic) == [t("<p id='two' class='c d'></p>")]
@test select(css".e", basic) == [t("<span class='e'>Some text here</span>")]
@test select(css".b", basic) == [t("<p id='one' class='a b'></p>"), t("<a class='b c'></a>")]

@test select(css"a.b", basic) == [t("<a class='b c'></a>")]
@test select(css"#one.b", basic) == [t("<p id='one' class='a b'></p>")]
@test select(css"p.b", basic) == [t("<p id='one' class='a b'></p>")]

@test select(css"p", basic) == [t("<p id='one' class='a b'></p>"), t("<p id='two' class='c d'></p>")]
@test select(css"span", basic) == [t("<span class='d'></span>"),
                                   t("<span class='e'>Some text here</span>"),
                                   t("<span>and more here</span>")]

# multi-level matches
@test select(css".d2 .d", basic) == [t("<span class='d'></span>")]
@test select(css".d2 span.e", basic) == [t("<span class='e'>Some text here</span>")]

