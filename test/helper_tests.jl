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
  <div>
    <div id='numeric_example'>31337</div>
  </div>
</body>
</html>
""")

@test text(basic) == "Some text here and more here 31337"
@test text(select(css".e", basic)) == ["Some text here"]
@test text(select(css".d2", basic)) == ["Some text here and more here"]
@test text(select(css".d2", basic)) == ["Some text here and more here"]
@test text(select(css"span", basic)) == ["", "Some text here", "and more here"]

@test parse(Int64, select(css"#numeric_example", basic)[1]) == 31337

