require! fs

gram-items = {}

gram-symbol-repeter = ->

gram-optional = ->


gram-line-parse = ->
  res = {}
  if it.0 is '%'
    res <<< optional: true
    return res <<< gram-line-parse it[1 to]*''

  if it.0 is '!'
    res <<< replace: true
    return res <<< gram-line-parse it[1 to]*''

  if it.0 is '"'
    res <<< literal: it[1 to elem-index \" tail it]*''
  else
    res <<< symbol: it

  if it[*-1] in <[ + * ? ]>
    res <<< repeter: it[*-1]
    if res.symbol?
      res.symbol = res.symbol[0 til -1]*''

  res

gram-or = ->
  res = []
  i = 0
  while i < it.length
    if it[i + 1]?.symbol is '|'
      $or = [it[i]]
      i++
      while it[i]?.symbol? and it[i].symbol is '|'
        $or.push it[i + 1]
        i += 2
      res.push or: $or
    else
      res.push it[i]
      i++
  res

gram-escape = ->
  res = new Buffer it.length
  open = false
  for l, i in it
    if l is '"'
      open = !open
    if open and l is ' '
      res.writeUInt8 1, i
    else if open and l is '='
      res.writeUInt8 2, i
    else
      res.writeUInt8 l.charCodeAt(0), i
  res.toString!replace /\\n/g, '\n'

gram-unescape = ->
  it |> map ->
    | '\u0001' in it  => it.replace /\001/g, ' '
    | '\u0002' in it  => it.replace /\002/g, '='
    | _               => it

gram-line-decl = ->
  parts = gram-unescape gram-escape(it).split ': '
  gram-items[parts.0] = gram-or map gram-line-parse, gram-unescape gram-escape(parts.1).split ' '

stdGram =
  Character: [
    or:
      * symbol: "Alphanum"
        optional: true
      * symbol: "SpeChar"
        optional: true
  ]
  SpeChar: [
    or:
      * literal: " "
      * literal: "/"
      * literal: "!"
      * literal: "@"
      * literal: "#"
      * literal: "$"
      * literal: "%"
      * literal: "^"
      * literal: "&"
      * literal: "*"
      * literal: "("
      * literal: ")"
      * literal: "_"
      * literal: "-"
      * literal: "="
      * literal: "+"
      * literal: "["
      * literal: "]"
      * literal: "{"
      * literal: "}"
      * literal: "|"
      * literal: "/"
      * literal: "?"
      * literal: "."
      * literal: ">"
      * literal: "<"
      * literal: ","
      * literal: ";"
      * literal: ":"
      * literal: "\\n"
      * literal: "\\"]
  Alphanum: [
    or:
      * symbol: 'Letter'
        optional: true
      * symbol: 'Digit'
        optional: true]
  Letter: [
    or:
      * literal: "a"
      * literal: "b"
      * literal: "c"
      * literal: "d"
      * literal: "e"
      * literal: "f"
      * literal: "g"
      * literal: "h"
      * literal: "i"
      * literal: "j"
      * literal: "k"
      * literal: "l"
      * literal: "m"
      * literal: "n"
      * literal: "o"
      * literal: "p"
      * literal: "q"
      * literal: "r"
      * literal: "s"
      * literal: "t"
      * literal: "u"
      * literal: "v"
      * literal: "w"
      * literal: "x"
      * literal: "y"
      * literal: "z"
      * literal: "A"
      * literal: "B"
      * literal: "C"
      * literal: "D"
      * literal: "E"
      * literal: "F"
      * literal: "G"
      * literal: "H"
      * literal: "I"
      * literal: "J"
      * literal: "K"
      * literal: "L"
      * literal: "M"
      * literal: "N"
      * literal: "O"
      * literal: "P"
      * literal: "Q"
      * literal: "R"
      * literal: "S"
      * literal: "T"
      * literal: "U"
      * literal: "V"
      * literal: "W"
      * literal: "X"
      * literal: "Y"
      * literal: "Z"]
  Digit: [
    or:
      * literal: "0"
      * literal: "1"
      * literal: "2"
      * literal: "3"
      * literal: "4"
      * literal: "5"
      * literal: "6"
      * literal: "7"
      * literal: "8"
      * literal: "9"]
  Number: [
    symbol: "Digit"
    repeter: "+"
    optional: true]


module.exports = (filename, done) ->
  fs.read-file filename, (err, buff) ->
    return done err if err?

    lines = buff.to-string!split \\n |> filter (.0 isnt '#' and it.length)

    each gram-line-decl, lines
    done null, stdGram <<< gram-items
    # inspect gram-items
