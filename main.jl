module WT
    using ArgParse

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
                push!(vectors, v)
                w2i[w] = length(w2i) + 1
                if length(w2i) == nmax
                    break
                end
            end
        end
        i2w = Dict(v => k for (k, v) in w2i)
        vectors = transpose(hcat(vectors...))
        return vectors, i2w, w2i
    end

    function vec_norm(mat, p=2)
        r = Array{Float64}([])
        for i in 1:size(mat, 1)
            push!(r, norm(mat[i, :], p))
        end
        return reshape(r, length(r), 1)
    end

    function div_norm(mat, p=2)
        mat_norm = vec_norm(mat, p)
        r = Array{Array{Float64}}([])
        for i in 1:size(mat, 1)
            push!(r, mat[i, :] / mat_norm[i])
        end
        r = transpose(hcat(r...))
        return r
    end

    function translate(words, sembs, si2w, tembs, ti2w)
        w2i = Dict(v => k for (k, v) in si2w)
        result_words = Array{String}([])
        for word in words
            if haskey(w2i, word)
                word_emb = sembs[w2i[word], :]
                scores = div_norm(tembs) * (word_emb / norm(word_emb))
                pred = sortperm(scores)[length(scores)]
                push!(result_words, ti2w[pred])
            else
                push!(result_words, "<UNK>")
            end
        end
        return result_words
    end

    function main()
        s = ArgParseSettings()
        @add_arg_table s begin
            "--output-path", "-o"
            "--input-path", "-i"
            "--input-vec", "-iv"
            "--output-vec", "-ov"
        end
        args = parse_args(ARGS, s)

        inv, ini2w, inw2i = load_vec(args["input-vec"])
        outv, outi2w, outw2i = load_vec(args["output-vec"])

        open(args["input-path"]) do io
            for (i, line) in enumerate(eachline(io))
                words = split(lowercase(line))
                pred_words = translate(words, inv, ini2w, outv, outi2w)
                pred_str = join(pred_words, " ")
            end
        end
    end

end


WT.main()
