require! fs

module.exports = (filename, grammar, done) ->

  mustFail = true
  fs.read-file filename, (err, buff) ->
    return done err if err?

    if buff[*-1] is 10
      buff = buff.slice 0, buff.length - 1

    file-parse-literal = ->
      return false if not buff.length
      /*log 'BUFF LENGTH', buff, buff.length, it.length, it*/
      file-literal = buff.slice 0, it.length
      # log 'Literal' file-literal, file-literal.toString!
      # log buff.length, it.length
      if file-literal.toString! is it
        buff := buff.slice file-literal.length
        return literal: file-literal.toString!

      /*throw 'Unexpected literal: "' + file-literal.toString! + '". Expected: "' + it + '"'*/
      false

    file-parse-or = ->
      return false if not buff.length
      # log 'or'
      for item in it
        if file-parse-item item
          return that

      # throw "OR: Unexpected literal at: #{buff.toString!slice 0 10}"
      false

    file-parse-repeter = ->
      repeter = it.repeter
      obj = {} <<< it
      delete obj.repeter
      if repeter is \*
        while file-parse-item obj
          that
      else if repeter is \+
        a = file-parse-item obj
        /*console.log \REPETER+ a*/
        throw "Repeter: '+' => Must appear at least once : #{JSON.stringify obj}" if not a
        do
          a
        while a = file-parse-item obj
      else if repeter is \?
        if file-parse-item obj
          that
      else
        false

    file-parse-item = ->
      | it.repeter?   => file-parse-repeter it
      | it.symbol?    => file-parse-symbol it.symbol
      | it.or?        => file-parse-or it.or
      | it.literal?   => file-parse-literal it.literal
        # | _             => log 'PAS SYMBOL', it; false

    not-empty = ->
      if not it?.length
        return false
      it

    file-get-literal = ->
      for k, item of it.value
        if item.literal
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

    done null, file-parse-symbol!
