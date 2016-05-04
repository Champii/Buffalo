global import require \prelude-ls

test = it
require! {
  assert
  async
  \../parse-file
}

verif = (gram, str, expected, done) ->
  buff = new Buffer str
  parseFile buff, gram, (err, res) ->
    return done err if err?

    if res !== expected
      return done new Error JSON.stringify res

    done!

fail = (gram, str, done) ->
  buff = new Buffer str
  parseFile buff, gram, (err, res) ->
    return done! if err?

    done new Error "Should have failed"

describe 'Parsing' ->

  test 'Should parse single Literal' ->
    gram = S: [literal: 'a']

    expected =
      symbol: 'S'
      literal: 'a'
      value:
        * literal: 'a'
        ...

    verif gram, "a", expected, it

  test 'Should fail to parse single Literal' ->
    gram = S: [literal: 'a']
    fail gram, "b",  it

  test 'Should parse multiple Literal' ->
    gram =
      S:
        * literal: 'a'
        * literal: 'b'

    expected =
      symbol: 'S'
      literal: 'ab'
      value:
        * literal: 'a'
        * literal: 'b'

    verif gram, "ab", expected, it

  test 'Should fail to parse multiple Literal' ->
    gram =
      S:
        * literal: 'a'
        * literal: 'b'

    async.series [
      * -> fail gram, "ba", it
      * -> fail gram, "ac", it
      * -> fail gram, "cb", it
      * -> fail gram, "pkasdw", it
      * -> fail gram, "", it]
      , it

  test 'Should parse multiple Literal 2' ->
    gram =
      S:
        * literal: 'ab'
        * literal: 'cd'

    expected =
      symbol: 'S'
      literal: 'abcd'
      value:
        * literal: 'ab'
        * literal: 'cd'

    verif gram, "abcd", expected, it

  test 'Should fail to parse multiple Literal 2' ->
    gram =
      S:
        * literal: 'ab'
        * literal: 'cd'

    async.series [
      * -> fail gram, "abd", it
      * -> fail gram, "ab", it
      * -> fail gram, "acd", it
      * -> fail gram, "cd", it
      * -> fail gram, "oajwd", it]
      , it

  test 'Should follow symbols' ->
    gram =
      S:
        * symbol: 'LETTER'
        * symbol: 'NUMBER'
      LETTER: [literal: 'a']
      NUMBER: [literal: '1']

    expected =
      symbol: 'S'
      literal: 'a1'
      value:
        * symbol: 'LETTER' literal: 'a' value: [literal: 'a']
        * symbol: 'NUMBER' literal: '1' value: [literal: '1']

    verif gram, "a1", expected, it

  test 'Should fail to follow symbols' ->
    gram =
      S:
        * symbol: 'LETTER'
        * symbol: 'NUMBER'
      LETTER: [literal: 'a']
      NUMBER: [literal: '1']

    async.series [
      * -> fail gram, "a", it
      * -> fail gram, "1", it
      * -> fail gram, "b1", it
      * -> fail gram, "11", it
      * -> fail gram, "fkls", it]
      , it

  test 'Should handle or' ->
    gram =
      S:
        * 'or':
            * literal: 'a'
            * literal: 'b'
            * literal: 'c'
        ...

    expected =
      symbol: 'S'
      literal: 'b'
      value: [literal: 'b']

    verif gram, "b", expected, it

  test 'Should fail to handle or' ->
    gram =
      S:
        * 'or':
            * literal: 'a'
            * literal: 'b'
            * literal: 'c'
        ...

    async.series [
      * -> fail gram, "d", it
      * -> fail gram, "ab", it
      * -> fail gram, "cb", it
      * -> fail gram, "fcb", it
      * -> fail gram, "cf", it]
      , it

  test 'Should handle optional' (done) ->
    gram =
      S:
        * literal: 'a'
        * literal: 'b' repeter: '?'
        * literal: 'c'

    expected1 =
      symbol: 'S'
      literal: 'abc'
      value:
        * literal: 'a'
        * literal: 'b'
        * literal: 'c'


    expected2 =
      symbol: 'S'
      literal: 'ac'
      value:
        * literal: 'a'
        * literal: 'c'

    async.series [
      * -> verif gram, "abc", expected1, it
      * -> verif gram, "ac", expected2, it]
      , done

  test 'Should fail optional' (done) ->
    gram =
      S:
        * literal: 'a'
        * literal: 'b' repeter: '?'
        * literal: 'c'

    async.series [
      * -> fail gram, "aaa", it
      * -> fail gram, "aac", it
      * -> fail gram, "a", it
      * -> fail gram, "b", it
      * -> fail gram, "c", it]
      , done
