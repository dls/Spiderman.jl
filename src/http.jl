function http_get(url :: AbstractString; max_tries=10)
    resp = nothing
    try
        resp = Requests.get(url) #, opts)
    catch e
        if max_tries <= 1
            throw(e)
        else
            return http_get(url; max_tries=max_tries-1)
        end
    end

    if resp.status == 503
        if max_tries <= 1
            throw("Error executing request : too many timeouts")
        else
            return http_get(url; max_tries=max_tries-1)
        end
    end

    return Gumbo.parsehtml(bytestring(resp.body))
end
