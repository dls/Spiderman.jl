# extend Gumbo's text() function to work on every kind of element
function text_join{T <: HTMLNode}(ns :: Array{T})
    output = []
    for n=ns
        for e=preorder(n)
            if typeof(e) == HTMLText
                push!(output, text(e))
            end
        end
    end
    join(output, " ")
end

import Gumbo.text
text(n :: HTMLNode) = text_join([n])
text(n :: HTMLDocument) = text(n.root)
text{T <: HTMLNode}(ns :: Array{T}) = [text(n) for n=ns]

import Base.parent
parent(n :: HTMLNode) = n.parent
parent(ns :: Array{HTMLNode}) = [parent(n) for n=ns]

import Base.parse
parse{T}(t::Type{T}, n :: HTMLNode) = parse(t, text(n))
parse{T}(t::Type{T}, n :: HTMLDocument) = parse(t, text(n))