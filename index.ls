global import require \prelude-ls

require! {util, \./parse-gram \./parse-file}

/*global.log = console.log
global.inspect = (...args) -> map (-> console.log util.inspect it, depth: null), args*/

module.exports = (grammarPath, filePath, done) ->
  parse-gram grammarPath, (err, grammar) ->
    return console.error err if err?

    /*inspect \Grammar: grammar*/

    parse-file filePath, grammar, (err, parsed) ->
      return console.error err if err?

      done parsed

/*module.exports \./test.gra \./test.file ->
  console.log \OK it*/
