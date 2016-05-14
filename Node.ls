class Node

  (@symbol, @literal = '', @children = []) ->
    map (~> it.parent = @), @children

  print: (level = 0) ->
    if @symbol.length
      console.log "#{repeat level, " "}#{@symbol} #{@literal}"
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

module.exports = Node
