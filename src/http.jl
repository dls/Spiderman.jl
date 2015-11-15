function http_get(url :: AbstractString; max_tries=10)
    resp = nothing
    try
        # opts = HTTPC.RequestOptions()
        resp = HTTPClient.get(url) #, opts)
    catch e
        if max_tries <= 1
            throw(e)
        else
            return http_get(url; max_tries=max_tries-1)
        end
    end

    if resp.http_code == 503
        if max_tries <= 1
            throw("Error executing request : too many timeouts")
        else
            return http_get(url; max_tries=max_tries-1)
        end
    end

    return Gumbo.parsehtml(bytestring(resp.body))
end