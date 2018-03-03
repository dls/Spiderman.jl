import Base.==

const no_attr_uuid = string(Base.Random.uuid4())

getattr_safe(n :: HTMLText, a :: AbstractString) = no_attr_uuid
getattr_safe(n :: HTMLNode, a :: AbstractString) = get(n.attributes, a, no_attr_uuid)

tag_safe(n :: HTMLText) = no_attr_uuid
tag_safe(n :: HTMLNode) = tag(n)

abstract type GumboPred end

immutable IsTag <: GumboPred; tag; end
IsTag(t :: AbstractString) = IsTag(Symbol(t))
matchp(p :: IsTag, n :: HTMLNode) = tag_safe(n) == p.tag
==(a :: IsTag, b :: IsTag) = a.tag == b.tag

immutable HasId <: GumboPred; id; end
matchp(p :: HasId, n :: HTMLNode) = getattr_safe(n, "id") == p.id
==(a :: HasId, b :: HasId) = a.id == b.id

immutable HasClass <: GumboPred; regex :: Regex; end
HasClass(s :: AbstractString) = HasClass(Regex("\\b$s\\b"))
matchp(p :: HasClass, n :: HTMLNode) = ismatch(p.regex, getattr_safe(n, "class"))
==(a :: HasClass, b :: HasClass) = a.regex == b.regex

immutable MatchGroup <: GumboPred; ps :: Array{GumboPred}; end
function matchp(ps :: MatchGroup, n :: HTMLNode)
    for p=ps.ps
        if !matchp(p, n)
            return false
        end
    end
    return true
end
==(a :: MatchGroup, b :: MatchGroup) = a.ps == b.ps


function _css_part_to_matcher(desc)
    function matcher(e)
        if e[1] == '#'
            HasId(e[2:end])
        elseif e[1] == '.'
            HasClass(e[2:end])
        else
            IsTag(e)
        end
    end

    preds = [matcher(e) for e=matchall(r"(#[\w-]+)|(\w+)|(\.[\w-]+)", desc)]
    if length(preds) == 1
        preds[1]
    else
        MatchGroup(preds)
    end
end

function compile_css(css)
    ops = split(strip(css), r"\s+")
    parts = GumboPred[_css_part_to_matcher(e) for e=ops]

    if length(parts) == 1
        parts[1]
    else
        parts
    end
end

macro css_str(css)
    quote
        $(compile_css(css))
    end
end


import Base.select
function select(p :: GumboPred, n :: HTMLNode, out = HTMLNode[] :: Array{HTMLNode})
    if matchp(p, n)
        push!(out, n)
    end
    for e=children(n)
        select(p, e, out)
    end
    out
end

function select(p :: GumboPred, ns :: Array{HTMLNode}, out = HTMLNode[] :: Array{HTMLNode})
    for n=ns
        select(p, n, out)
    end
    out
end

function select(ps :: Array{GumboPred}, items :: Array{HTMLNode}, out = HTMLNode[] :: Array{HTMLNode})
    @assert length(ps) > 0

    let p=ps[1]
        next_items = HTMLNode[]
        for e=items
            select(p, e, next_items)
        end
        items = next_items
    end

    if length(ps) == 1
        return items
    end

    for p=ps[2:end]
        next_items = HTMLNode[]
        for e=items
            for c=children(e)
                select(p, c, next_items)
            end
        end
        items = next_items
    end
    items
end

select(ps :: Array{GumboPred}, n :: HTMLNode, out = HTMLNode[] :: Array{HTMLNode}) =
    select(ps, [n], out)

select(p :: GumboPred, d :: HTMLDocument, out = HTMLNode[] :: Array{HTMLNode}) =
    select(p, children(d.root), out)

select(ps :: Array{GumboPred}, d :: HTMLDocument, out = HTMLNode[] :: Array{HTMLNode}) =
    select(ps, children(d.root), out)
