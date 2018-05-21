module WT


    function load_vec(path, nmax=50000)
        vectors = Array{Array{Float64}}([])
        w2i = Dict{String, Int64}()
        open(path) do io
            for (i, line) in enumerate(eachline(io))
                if i == 1
                    continue
                end
                _splitted= split(rstrip(line))
                w = _splitted[1]
                v = [parse(Float64, ss) for ss in _splitted[2:length(_splitted)]]
                vectors = push!(vectors, v)
                w2i[w] = length(w2i)
                if length(w2i) == nmax
                    break
                end
            end
        end
        i2w = Dict(v => k for (k, v) in w2i)
        return vectors, i2w, w2i
    end


    function translate(words, sembs, si2w, tembs, ti2w)
        w2i = Dict(v => k for (k, v) in si2w)
        result_words = Array{String}([])
        for word in words
            if haskey(w2i, word)
                word_emb = sembs[w2i[word]]
                scores = (tembs / )
            else
            end
        end
    end


end
