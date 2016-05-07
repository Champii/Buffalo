if not global.map?
  global import require \prelude-ls

require! fs

module.exports = (buff, grammar, done) ->

  return done new Error "File empty" if not buff.length

  file-parse-literal = ->
    throw new Error 'Unexpected end of file' if not buff.length

    file-literal = buff.slice 0, it.length

    if file-literal.toString! is it
      buff := buff.slice file-literal.length
      return literal: file-literal.toString!

    throw new Error 'Unexpected literal: "' + file-literal.toString! + '". Expected: "' + it + '" at "' + buff + '"'

  file-parse-or = ->
    throw new Error 'Unexpected end of file' if not buff.length

    for item in it
      /*b = Buffer.from buff*/
      try
        if file-parse-item item
          return that
      catch e
        /*buff := b*/
        continue

    throw new Error "OR: Unexpected literal at: '#{buff.toString!slice 0 10}'"

  file-parse-repeter = ->
    repeter = it.repeter
    obj = {} <<< it
    delete obj.repeter
    if repeter is \*
      save = []
      try
        while file-parse-item obj
          save.push that
          that
      catch e
        return save

    else if repeter is \+
      save = []
      save.push file-parse-item obj

      throw new Error "Repeter: '+' => Must appear at least once : #{JSON.stringify obj}" if not save.length
      try
        while file-parse-item obj
          save.push that
        save
      catch e
        return save

    else if repeter is \?
      try
        if file-parse-item obj
          that
      catch e
        return false
    else
      false


  file-parse-item = ->
    | it.repeter?   => file-parse-repeter it
    | it.symbol?    => file-parse-symbol it.symbol
    | it.or?        => file-parse-or it.or
    | it.literal?   => file-parse-literal it.literal
    | _             => throw new Error 'PAS SYMBOL'

  not-empty = ->
    if not it?.length
      return false
    it

  file-get-literal = ->
    for item, k in it.value
      if item?.literal? and it?.literal?
        it.literal += item.literal

  file-parse-symbol = (symbol = \S) ->
    res =
      symbol: symbol
      literal: ''
      value: []
    res.value = compact map file-parse-item, grammar[symbol]
    res.value = flatten not-empty res.value
    file-get-literal res
    # log 'Res?' res
    if not res.value?.length
      return false
    res

  try
    ast = file-parse-symbol!
  catch e
    return done new Error e

  if buff.length
    return done new Error "Expected end of file: #{buff}"

  done null, ast
