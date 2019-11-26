mutable struct Note
    pitch :: String
    octave :: String
    duration :: String
    tieflag :: Bool
    function Note(p="c", o="'", d="4"; tie=false)
        new(p, o, d; tie)
    end
end

function Base.show(io::IO, note::Note)
    print(io, string(note.pitch, note.octave, note.duration, note.tieflag == true ? "~" : ""))
end

"""
makerhythm(notes::Int=6, totalduration::Int=16)

Returns a list of randomly generated integers representing durations given in subdivisions of the beat.

The meter need not be specified.  Functions consuming a rhythm can interpret the subdivisions as 16th notes,
8th note triplets, etc. and can incorporate the rhythm in any meter.
"""
function makerhythm(notes::Int=4, totalduration::Int=8)
    rhythm = fill(1, notes)
    while sum(rhythm) < totalduration
        note = rand(1:notes)
        rhythm[note] += 1
    end
    return rhythm
end

function writely(filename::String, notes::Array{Note})
    fout = open(filename, "w")
    println(fout, raw"\version \"2.18.2\"")
    println(fout, "{")

    for note in notes
        lynote = string(note) # the show function converts a Note to lilypond string form
        print(fout, lynote, " ")
    end

    # close the file
    println(fout, "}")
    close(fout)
end

function melody(nn=4) # nn = number of notes
    # generate random notes
    notes = []
    for n in 1:nn
        pitch = rand('a' : 'g')
        note = Note(string(pitch))
        push!(notes, note)
    end
    return notes
end

# writely("melody.ly", melody(8))

"""
given: list of durations, subdivision of the beat, groupsize
return: a list of Note on pitch c'' in the given rhythm
limitations: no tuple capability
 """
function rhythmly(lod::Array{Int}, groupsize::Int) # lod = list of durations
    output = []
    group = 0
    while length(lod) > 0
        duration = popfirst!(lod)
        if duration + group < groupsize
            push!(output, Note("c", "'", string(duration)))
            group += duration
        elseif duration + group == groupsize
            push!(output, Note("c", "'", string(duration)))
            group = 0
        elseif duration + group > groupsize
            leftnote = groupsize - group
            rightnote = duration - leftnote
            group = rightnote
            push!(output, Note("c", "'", string(leftnote), tie=true))
            push!(output, Note("c", "'", string(rightnote)))
        else
            error("The if-elseif clause didn't catch all cases!")
        end
    end
    return output
end


# function rhythmly(lod, groupsize, group=0, output="")
#     if length(lod) == 0
#         return output
#     end

#     if lod[1] + group < groupsize # if the note will fit in the beat ...
#         rhythmly(lod[2:end], groupsize, group+lod[1], string(output, lod[1], ' '))
#     elseif lod[1] + group == groupsize # if the note completes the beat exactly ...
#         rhythmly(lod[2:end], groupsize, 0, string(output, lod[1], ' '))
#     elseif lod[1] + group > groupsize # if the note won't fit in the current beat ...
#         leftnote = groupsize - group
#         rightnote = lod[1] - leftnote
#         group = rightnote
#         rhythmly(lod[2:end], groupsize, group, string(output, leftnote, "~ ", rightnote, ' '))
#     else
#         error("The if-elseif clause didn't catch all cases!")
#     end
# end



function rhythmly(lod, rvalue, groupsize, group=0, output=[])
    if length(lod) == 0
        return output
    end

    if lod[1] + group < groupsize # if the note will fit in the beat ...
        note = Note("c", "'", )
        rhythmly(lod[2:end], groupsize, group+lod[1], string(output, lod[1], ' '))
    elseif lod[1] + group == groupsize # if the note completes the beat exactly ...
        rhythmly(lod[2:end], groupsize, 0, string(output, lod[1], ' '))
    elseif lod[1] + group > groupsize # if the note won't fit in the current beat ...
        leftnote = groupsize - group
        rightnote = lod[1] - leftnote
        group = rightnote
        rhythmly(lod[2:end], groupsize, group, string(output, leftnote, "~ ", rightnote, ' '))
    else
        error("The if-elseif clause didn't catch all cases!")
    end
end




