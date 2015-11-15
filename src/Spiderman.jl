module Spiderman
using Gumbo
import HTTPClient

include("css.jl")
export @css_str, compile_css, collect

include("helpers.jl")
export text, parent, parse

include("http.jl")

end # module
