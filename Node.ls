class Node

  (@symbol, @literal = '', @children = []) ->
    map (~> it.parent = @), @children

  print: (level = 0) ->
    if @symbol.length
      console.log "#{repeat level, " "}#{@symbol} #{@literal.replace /\n/gi ''}"
    map (.print level + 2), @children

  left: ->
    prev = null
    for child in @parent.children
      return prev if child is @
      prev = child
    return null

  right: ->
    next = false
    for child in @parent.children
      return child if next
      next = true if child is @
    return null

  contains: (symb) ->
    if @symbol is symb
      return true
    return any (.contains symb), @children

  map: (fn) ->
    @children = map fn, @children
    map @~map, @children

  filter: (fn) ->
    @children = filter fn, @children
    map (.filter fn), @children

  filterOptional: ->
    @filter -> not it.optional

module.exports = Node
