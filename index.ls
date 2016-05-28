global import require \prelude-ls

require! {util, fs, \./parse-gram \./parse-file}

/*global.log = console.log*/

global.inspect = (...args) -> map (-> console.log util.inspect it, depth: null), args

module.exports = (grammarPath, filePath, done) ->
  parse-gram grammarPath, (err, grammar) ->
    return console.error err if err?

    /*inspect \Grammar: grammar*/

    fs.read-file filePath, (err, buff) ->
      return done new Error err if err?
      return done new Error "File empty: #{filename}" if not buff.length

      if buff[*-1] is 10
        buff = buff.slice 0, buff.length - 1

      parse-file buff, grammar, (err, res) ->
        return done err if err?

        res.filterOptional!
        res.mapReplace!

        done null res

/*module.exports \./exemples/test.gra \./exemples/test.file ->
  return console.error it if it?
  &1.filterOptional!
  &1.mapReplace!
  inspect &1
  &1.print!
*/
/*  epureAst = ->
    it.value = it.value
      |> filter -> it.symbol not in <[ Alphanum Digit Letter ]>
      |> filter -> not (it.literal? and keys it .length is 1)
      |> map -> epureAst it
    if not it.value.length
      delete it.value
    it

  inspect it, epureAst &1*/
