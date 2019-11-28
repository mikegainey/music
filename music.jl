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
    println(fout, raw"\language \"english\"")
    println(fout, raw"\clef \"treble\"")
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

# needed for rhythmly
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
"""
function rhythmly(lod, groupsize)
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
        ns = rhythmly(ds, 4)
        append!(music, ns)
    end
    filename = "testrhythm.ly"
    writely(filename, music)
    println(filename, " should be available for lilypond compilation.")
    nothing
end
