module WT
    using ArgParse
    using ProgressMeter
    using JSON

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

    function translate(word, sembs, si2w, tembs, ti2w)
        w2i = Dict(v => k for (k, v) in si2w)
        if haskey(w2i, word)
            word_emb = sembs[w2i[word], :]
            scores = div_norm(tembs) * (word_emb / norm(word_emb))
            pred = sortperm(scores)[length(scores)]
            return ti2w[pred]
        else
            return "<UNK>"
        end
    end

    function main()
        s = ArgParseSettings()
        @add_arg_table s begin
            "--output-path", "-o"
            "--input-vec", "-s"
            "--output-vec", "-t"
        end
        args = parse_args(ARGS, s)

        println("Loading datas...")
        inv, ini2w, inw2i = load_vec(args["input-vec"])
        outv, outi2w, outw2i = load_vec(args["output-vec"])

        final_dict = Dict{String, String}()

        println("Start translating...")
        @showprogress 1 "Translating" for (i, word) in ini2w
            pred_word = translate(word, inv, ini2w, outv, outi2w)
            final_dict[word] = pred_word
        end

        println("Writign to file...")

        open(args["output-path"], "w") do f
            JSON.print(f, final_dict)
        end
    end

end


WT.main()
