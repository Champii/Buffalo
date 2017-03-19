global import require \prelude-ls

require! {util, fs, \./parse-gram \./parse-file}

/*global.log = console.log*/

global.inspect = (...args) -> map (-> console.log util.inspect it, depth: null), args

module.exports = (grammarDef, input) ->
  grammar = parse-gram grammarDef
  # inspect \Grammar: grammar

  # if buff[*-1] is 10
  #   buff = buff.slice 0, buff.length - 1

  [err, res] = parse-file input, grammar

  return err if err?

  res.filterOptional!
  res.mapReplace!
  # inspect \res: res

  res

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
