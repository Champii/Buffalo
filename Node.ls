class Node

  (@symbol, @literal = '', @children = []) ->
    map (~> it.parent = @), @children

  print: (level = 0) ->
    if @symbol.length
      console.log "
        #{repeat level, " "}
        #{@symbol}
      " + " " + if not @children.length or all (-> not it.symbol.length), @children
        @literal.replace '\n' ''
      else
        ""
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
    map (.map fn), @children

  filter: (fn) ->
    @children = filter fn, @children
    map (.filter fn), @children

  filterOptional: ->
    @filter -> not it.optional

  mapReplace: ->
    map (.mapReplace!), @children

    @children = @children
      |> map -> if it.replace => it.children else it
      |> flatten
      |> each ~> it.parent = @

  firstLeave: ->
    if not @children.length
      @
    else
      @children.0.firstLeave!

module.exports = Node
