global import require \prelude-ls

require! {util, \./parse-gram \./parse-file}

/*global.log = console.log*/

global.inspect = (...args) -> map (-> console.log util.inspect it, depth: null), args

module.exports = (grammarPath, filePath, done) ->
  parse-gram grammarPath, (err, grammar) ->
    return console.error err if err?

    inspect \Grammar: grammar

    parse-file filePath, grammar, (err, parsed) ->
      return console.error err if err?

      done parsed

module.exports \./test.gra \./test.file ->
  inspect it

  tabs = 0
  parse = ->
    it.value
      |> filter -> it.symbol not in <[ Alphanum Delimiter Letter Digit ]>
      |> map ->
        it = it.value.0 if it.symbol is \Value
        tabs := tabs + 2
        res = switch
          | it.symbol? =>
            console.log [til tabs].map(-> ' ')*'', it.symbol#, '  ', it.literal
            parse it
        tabs := tabs - 2

  parse it
