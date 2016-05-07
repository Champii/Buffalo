global import require \prelude-ls

require! {util, fs, \./parse-gram \./parse-file}

/*global.log = console.log*/

global.inspect = (...args) -> map (-> console.log util.inspect it, depth: null), args

module.exports = (grammarPath, filePath, done) ->
  parse-gram grammarPath, (err, grammar) ->
    return console.error err if err?

    inspect \Grammar: grammar

    fs.read-file filePath, (err, buff) ->
      return done new Error err if err?
      return done new Error "File empty: #{filename}" if not buff.length

      if buff[*-1] is 10
        buff = buff.slice 0, buff.length - 1

      parse-file buff, grammar, done

module.exports \./exemples/newLang.gra \./exemples/newLang.file ->
  inspect it, &1

#  tabs = 0
#  parse = ->
#    /*console.log 'PARSE' it*/
#    it.value
#      |> filter -> it.symbol not in <[ Alphanum Letter Digit ]>
#      |> map ->
#        it = it.value.0 if it.symbol is \Value
#        tabs := tabs + 2
#        res = switch
#          | it.symbol? =>
#            console.log [til tabs].map(-> ' ')*'', it.symbol#, '  ', it.literal
#            parse it
#        tabs := tabs - 2

#  parse it
