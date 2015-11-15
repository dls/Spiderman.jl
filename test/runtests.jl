using Spiderman
using Gumbo
using Base.Test

# testing helpers
t(html) =
    parsehtml(html).root[2][1]

include("css_tests.jl")
include("helper_tests.jl")
include("examples.jl")