// Generated by LiveScript 1.5.0
(function(){
  var util, fs, parseGram, parseFile;
  import$(global, require('prelude-ls'));
  util = require('util');
  fs = require('fs');
  parseGram = require('./parse-gram');
  parseFile = require('./parse-file');
  /*global.log = console.log*/
  global.inspect = function(){
    var args, res$, i$, to$;
    res$ = [];
    for (i$ = 0, to$ = arguments.length; i$ < to$; ++i$) {
      res$.push(arguments[i$]);
    }
    args = res$;
    return map(function(it){
      return console.log(util.inspect(it, {
        depth: null
      }));
    }, args);
  };
  module.exports = function(grammarDef, input){
    var grammar, ref$, err, res;
    grammar = parseGram(grammarDef);
    ref$ = parseFile(input, grammar), err = ref$[0], res = ref$[1];
    if (err != null) {
      return err;
    }
    res.filterOptional();
    res.mapReplace();
    return res;
  };
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
  function import$(obj, src){
    var own = {}.hasOwnProperty;
    for (var key in src) if (own.call(src, key)) obj[key] = src[key];
    return obj;
  }
}).call(this);
