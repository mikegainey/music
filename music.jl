mutable struct Note
    pitch :: String
    octave :: String
    duration :: String
    tieflag :: Bool
end

function Note(p="c", o="''", d="4"; tie=false)
    Note(p, o, d, tie)
end

function Base.show(io::IO, note::Note)
    print(io, string(note.pitch, note.octave, note.duration, note.tieflag == true ? "~" : ""))
end

"""
makerhythm(notes::Int=4, totalduration::Int=8)

Returns a list of randomly generated integers representing durations given in subdivisions of the beat.

The meter need not be specified.  Functions consuming a rhythm can interpret the subdivisions as 16th notes,
8th note triplets, etc. and can incorporate the rhythm in any meter.
"""
function makerhythm(notes::Int=4, totalduration::Int=8) :: Array{Int}
    rhythm = fill(1, notes)
    while sum(rhythm) < totalduration
        note = rand(1:notes)
        rhythm[note] += 1
    end
    return rhythm
end

"""
writely(filename::String, notes::Array{Note})

Given a filename and list of Note objects, write the corresponding lilypond file.
"""
function writely(filename::String, notes; time="4/4")
    fout = open(filename, "w")
    println(fout, raw"\version \"2.18.2\"")
    println(fout, "{")
    println(fout, raw"\time ", time)

    for note in notes
        lynote = string(note) # the show function converts a Note to lilypond string form
        print(fout, lynote, " ")
    end

    # close the file
    println(fout, "\n}")
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

d2lyd = Dict(1 => "16",
             2 => "8",
             3 => "8.",
             4 => "4",
             6 => "4.",
             7 => "4..",
             8 => "2"
             )

"""
rhythmly(lod, groupsize, group=0, output=[])

Given a list of integer durations, (output of makerhythm), like [6, 3, 4, 3]
and a groupsize, for now limited to 4
Returns a list of Notes with the specified rhythm on the pitch c''

error: rhythmly([1,2,6,1,1,3,1,1], 4) # needs three notes tied together; how do I fix this?
"""
function rhythmly(lod::Array{Int}, groupsize::Int, remaining::Int=0, output::Array{Note}=Note[]) :: Array{Note}
    @show lod, groupsize, remaining, output
    if length(lod) == 0 # the base case
        return output
    end

    if groupsize > 8; groupsize = 8; end # max groupsize for now
    duration = lod[1] # the head of the list
    tail = lod[2:end] # the tail of the list

    if duration + remaining ≤ groupsize # if the note will fit in the beat ...
        if duration == 5 # because there is no one note of this duration, use two notes with a tie
            note1 = Note("c", "''", 4, tie=true)
            note2 = Note("c", "''", 1)
            rhythmly(tail, groupsize, (remaining+duration) % groupsize, vcat(output, note1, note2))
        else
            note = Note("c", "''", d2lyd[duration])
            rhythmly(tail, groupsize, (remaining+duration) % groupsize, vcat(output, note))
        end
    elseif duration + remaining > groupsize # if the note won't fit in the current beat ...
        n1d = groupsize - remaining
        note1 = Note("c", "''", d2lyd[n1d], tie=true)
        n2d = duration - n1d
        note2 = Note("c", "''", d2lyd[n2d])
        remaining = n2d % groupsize
        rhythmly(tail, groupsize, remaining, vcat(output, note1, note2))
    else
        error("The if-elseif clause didn't catch all cases!")
    end
end


function rhythmly2(lod, groupsize)
    @assert groupsize ≤ 4
    output = []
    remaining = 0
    while length(lod) > 0
        duration = popfirst!(lod)
        if (remaining + duration) ≤ groupsize
            push!(output, Note("c", "''", d2lyd[duration]))
            remaining = (remaining + duration) % groupsize
        else # the duration won't fit in the group
            split1 = groupsize - remaining # the part that will fit in the group
            split2 = duration - split1 # the leftover part
            push!(output, Note("c", "''", d2lyd[split1], tie=true))
            pushfirst!(lod, split2) # put the leftover part back in the input list
            remaining = 0
        end
    end
    return output
end

function test(n)
    music = []
    for measure in 1:n
        ds = makerhythm(8, 16)
        ns = rhythmly2(ds, 4)
        append!(music, ns)
    end
    filename = "testrhythm.ly"
    writely(filename, music)
    println(filename, " should be available for lilypond compilation.")
    nothing
end
