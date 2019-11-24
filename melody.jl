mutable struct Note
    pitch :: String
    octave :: String
    duration :: String
    function Note(p="c", o="'", d="4")
        new(p, o, d)
    end
end

function Base.show(io::IO, note::Note)
    print(io, string(note.pitch, note.octave, note.duration))
end

D2R = Dict(1 => "16",
           2 => "8",
           3 => "8.",
           4 => "4"
)

function writely(filename, notes) # where notes is a list of Note objects
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

function rhythm(notes=6, duration=16) # duration given in number of 16th notes
    rhythm = fill(1, notes)
    while sum(rhythm) < duration
        note = rand(1:notes)
        rhythm[note] += 1
    end
    return rhythm
end



# writely("melody.ly", melody(8))
