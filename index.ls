require! {util, \./parse-gram \./parse-file}

global import require \prelude-ls

global.log = console.log
global.inspect = (...args) -> map (-> console.log util.inspect it, depth: null), args

parse-gram \./test.gra (err, grammar) ->
  return console.error err if err?

  inspect grammar

  parse-file \./test.file grammar, (err, parsed) ->
    return console.error err if err?

    inspect parsed
