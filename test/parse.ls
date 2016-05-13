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
      return done new Error 'Unexpected result: ' + JSON.stringify(res) + ' \nExpected: ' + JSON.stringify expected

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
      NUMBER: [literal: '0']

    expected =
      symbol: 'S'
      literal: 'a0'
      value:
        * symbol: 'LETTER' literal: 'a' value: [literal: 'a']
        * symbol: 'NUMBER' literal: '0' value: [literal: '0']

    verif gram, "a0", expected, it

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

  test 'Should handle complexe or' ->
    gram =
      S: [
        * symbol: 'LETTER' repeter: '*'
        * symbol: 'NUMBER' repeter: '*'
        * symbol: 'ALPHANUMERIC' repeter: '*']
      ALPHANUMERIC: [
        or:
          * symbol: 'LETTER'
          * symbol: 'NUMBER']
      LETTER: [
        or:
          * literal: "a"
          * literal: "b"
          * literal: "c"
          * literal: "d"
          * literal: "e"
          * literal: "f"
          * literal: "g"
          * literal: "h"
          * literal: "i"
          * literal: "j"
          * literal: "k"
          * literal: "l"
          * literal: "m"
          * literal: "n"
          * literal: "o"
          * literal: "p"
          * literal: "q"
          * literal: "r"
          * literal: "s"
          * literal: "t"
          * literal: "u"
          * literal: "v"
          * literal: "w"
          * literal: "x"
          * literal: "y"
          * literal: "z"]
      NUMBER: [
        or:
          * literal: "0"
          * literal: "1"
          * literal: "2"
          * literal: "3"
          * literal: "4"
          * literal: "5"
          * literal: "6"
          * literal: "7"
          * literal: "8"
          * literal: "9"]

    expected1 =
      symbol: 'S'
      literal: 'abcz'
      value:
        * symbol: 'LETTER' literal: 'a' value: [literal: 'a']
        * symbol: 'LETTER' literal: 'b' value: [literal: 'b']
        * symbol: 'LETTER' literal: 'c' value: [literal: 'c']
        * symbol: 'LETTER' literal: 'z' value: [literal: 'z']

    expected2 =
      symbol: 'S'
      literal: '487'
      value:
        * symbol: 'NUMBER' literal: '4' value: [literal: '4']
        * symbol: 'NUMBER' literal: '8' value: [literal: '8']
        * symbol: 'NUMBER' literal: '7' value: [literal: '7']

    expected3 =
      symbol: 'S'
      literal: '4s8a'
      value:
        * symbol: 'NUMBER' literal: '4' value: [literal: '4']
        * symbol: 'ALPHANUMERIC' literal: 's' value: [symbol: 'LETTER' literal: 's' value: [literal: 's']]
        * symbol: 'ALPHANUMERIC' literal: '8' value: [symbol: 'NUMBER' literal: '8' value: [literal: '8']]
        * symbol: 'ALPHANUMERIC' literal: 'a' value: [symbol: 'LETTER' literal: 'a' value: [literal: 'a']]

    async.auto [
      * -> verif gram, 'abcz', expected1, it
      * -> verif gram, '487', expected2, it
      * -> verif gram, '4s8a', expected3, it]
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

  test 'Should handle optional repetition' (done) ->
    gram =
      S:
        * literal: 'a'
        * literal: 'b' repeter: '*'
        * literal: 'c'

    expected1 =
      symbol: 'S'
      literal: 'ac'
      value:
        * literal: 'a'
        * literal: 'c'

    expected2 =
      symbol: 'S'
      literal: 'abc'
      value:
        * literal: 'a'
        * literal: 'b'
        * literal: 'c'

    expected3 =
      symbol: 'S'
      literal: 'abbbbbc'
      value:
        * literal: 'a'
        * literal: 'b'
        * literal: 'b'
        * literal: 'b'
        * literal: 'b'
        * literal: 'b'
        * literal: 'c'

    async.series [
      * -> verif gram, "ac", expected1, it
      * -> verif gram, "abc", expected2, it
      * -> verif gram, "abbbbbc", expected3, it]
      , done

  test 'Should fail optional repetition' (done) ->
    gram =
      S:
        * literal: 'a'
        * literal: 'b' repeter: '*'
        * literal: 'c'

    async.series [
      * -> fail gram, "a", it
      * -> fail gram, "b", it
      * -> fail gram, "c", it
      * -> fail gram, "adc", it]
      , done

  test 'Should handle complexe optional repetition' (done) ->
    gram =
      S:
        * literal: 'a' repeter: '*'
        * literal: 'b' repeter: '*'
        * literal: 'c' repeter: '*'

    expected1 =
      symbol: 'S'
      literal: ''
      value: []

    expected2 =
      symbol: 'S'
      literal: 'a'
      value:
        * literal: 'a'
        ...

    expected3 =
      symbol: 'S'
      literal: 'b'
      value:
        * literal: 'b'
        ...

    expected4 =
      symbol: 'S'
      literal: 'c'
      value:
        * literal: 'c'
        ...
    expected5 =
      symbol: 'S'
      literal: 'ab'
      value:
        * literal: 'a'
        * literal: 'b'

    expected6 =
      symbol: 'S'
      literal: 'ac'
      value:
        * literal: 'a'
        * literal: 'c'

    expected7 =
      symbol: 'S'
      literal: 'abc'
      value:
        * literal: 'a'
        * literal: 'b'
        * literal: 'c'

    expected8 =
      symbol: 'S'
      literal: 'aacc'
      value:
        * literal: 'a'
        * literal: 'a'
        * literal: 'c'
        * literal: 'c'

    expected9 =
      symbol: 'S'
      literal: 'bbcc'
      value:
        * literal: 'b'
        * literal: 'b'
        * literal: 'c'
        * literal: 'c'

    async.series [
      * -> verif gram, 'a', expected2, it
      * -> verif gram, 'b', expected3, it
      * -> verif gram, 'c', expected4, it
      * -> verif gram, 'ab', expected5, it
      * -> verif gram, 'ac', expected6, it
      * -> verif gram, 'abc', expected7, it
      * -> verif gram, 'aacc', expected8, it
      * -> verif gram, 'bbcc', expected9, it]
      , done

  test 'Should handle required repetition' (done) ->
    gram =
      S:
        * literal: 'a'
        * literal: 'b' repeter: '+'
        * literal: 'c'

    expected2 =
      symbol: 'S'
      literal: 'abc'
      value:
        * literal: 'a'
        * literal: 'b'
        * literal: 'c'

    expected3 =
      symbol: 'S'
      literal: 'abbbbbc'
      value:
        * literal: 'a'
        * literal: 'b'
        * literal: 'b'
        * literal: 'b'
        * literal: 'b'
        * literal: 'b'
        * literal: 'c'

    async.series [
      * -> verif gram, "abc", expected2, it
      * -> verif gram, "abbbbbc", expected3, it]
      , done

  test 'Should fail required repetition' (done) ->
    gram =
      S:
        * literal: 'a'
        * literal: 'b' repeter: '+'
        * literal: 'c'

    async.series [
      * -> fail gram, "a", it
      * -> fail gram, "b", it
      * -> fail gram, "c", it
      * -> fail gram, "ac", it
      * -> fail gram, "adc", it]
      , done

  test 'Should success all together' ->
    gram =
      S:
        * literal: '{'
        * symbol: 'ALPHANUMERIC' repeter: '+'
        * literal: '}'
      ALPHANUMERIC: [
        or:
          * symbol: 'LETTER'
          * symbol: 'NUMBER']
      LETTER: [
        or:
          * literal: "a"
          * literal: "b"
          * literal: "c"
          * literal: "d"
          * literal: "e"
          * literal: "f"
          * literal: "g"
          * literal: "h"
          * literal: "i"
          * literal: "j"
          * literal: "k"
          * literal: "l"
          * literal: "m"
          * literal: "n"
          * literal: "o"
          * literal: "p"
          * literal: "q"
          * literal: "r"
          * literal: "s"
          * literal: "t"
          * literal: "u"
          * literal: "v"
          * literal: "w"
          * literal: "x"
          * literal: "y"
          * literal: "z"]
      NUMBER: [
        or:
          * literal: "0"
          * literal: "1"
          * literal: "2"
          * literal: "3"
          * literal: "4"
          * literal: "5"
          * literal: "6"
          * literal: "7"
          * literal: "8"
          * literal: "9"]

    expected =
      symbol: 'S'
      literal: '{a5bv98z}'
      value:
        * literal: '{'
        * symbol: 'ALPHANUMERIC' literal: 'a' value: [symbol: 'LETTER' literal: 'a' value: [literal: 'a']]
        * symbol: 'ALPHANUMERIC' literal: '5' value: [symbol: 'NUMBER' literal: '5' value: [literal: '5']]
        * symbol: 'ALPHANUMERIC' literal: 'b' value: [symbol: 'LETTER' literal: 'b' value: [literal: 'b']]
        * symbol: 'ALPHANUMERIC' literal: 'v' value: [symbol: 'LETTER' literal: 'v' value: [literal: 'v']]
        * symbol: 'ALPHANUMERIC' literal: '9' value: [symbol: 'NUMBER' literal: '9' value: [literal: '9']]
        * symbol: 'ALPHANUMERIC' literal: '8' value: [symbol: 'NUMBER' literal: '8' value: [literal: '8']]
        * symbol: 'ALPHANUMERIC' literal: 'z' value: [symbol: 'LETTER' literal: 'z' value: [literal: 'z']]
        * literal: '}'

    verif gram, "{a5bv98z}", expected, it

  test 'Should fail all together' ->
    gram =
      S:
        * literal: '{'
        * symbol: 'ALPHANUMERIC' repeter: '+'
        * literal: '}'
      ALPHANUMERIC: [
        or:
          * symbol: 'LETTER'
          * symbol: 'NUMBER']
      LETTER: [
        or:
          * literal: "a"
          * literal: "b"
          * literal: "c"
          * literal: "d"
          * literal: "e"
          * literal: "f"
          * literal: "g"
          * literal: "h"
          * literal: "i"
          * literal: "j"
          * literal: "k"
          * literal: "l"
          * literal: "m"
          * literal: "n"
          * literal: "o"
          * literal: "p"
          * literal: "q"
          * literal: "r"
          * literal: "s"
          * literal: "t"
          * literal: "u"
          * literal: "v"
          * literal: "w"
          * literal: "x"
          * literal: "y"
          * literal: "z"]
      NUMBER: [
        or:
          * literal: "0"
          * literal: "1"
          * literal: "2"
          * literal: "3"
          * literal: "4"
          * literal: "5"
          * literal: "6"
          * literal: "7"
          * literal: "8"
          * literal: "9"]

    async.series [
      * -> fail gram, 'a', it
      * -> fail gram, '{}', it
      * -> fail gram, '{', it
      * -> fail gram, '}', it
      * -> fail gram, '{.}', it]
      , it

  test 'Should success on complexe' ->
    gram =
      S:
        * literal: '{'
        * symbol: 'ALPHANUMERIC' repeter: '+'
        * literal: '}'
      ALPHANUMERIC: [
        or:
          * symbol: 'LETTER'
          * symbol: 'NUMBER']
      LETTER: [
        or:
          * literal: "a"
          * literal: "b"
          * literal: "c"
          * literal: "d"
          * literal: "e"
          * literal: "f"
          * literal: "g"
          * literal: "h"
          * literal: "i"
          * literal: "j"
          * literal: "k"
          * literal: "l"
          * literal: "m"
          * literal: "n"
          * literal: "o"
          * literal: "p"
          * literal: "q"
          * literal: "r"
          * literal: "s"
          * literal: "t"
          * literal: "u"
          * literal: "v"
          * literal: "w"
          * literal: "x"
          * literal: "y"
          * literal: "z"]
      NUMBER: [
        or:
          * literal: "0"
          * literal: "1"
          * literal: "2"
          * literal: "3"
          * literal: "4"
          * literal: "5"
          * literal: "6"
          * literal: "7"
          * literal: "8"
          * literal: "9"]

    expected =
      symbol: 'S'
      literal: '{a5bv98z}'
      value:
        * literal: '{'
        * symbol: 'ALPHANUMERIC' literal: 'a' value: [symbol: 'LETTER' literal: 'a' value: [literal: 'a']]
        * symbol: 'ALPHANUMERIC' literal: '5' value: [symbol: 'NUMBER' literal: '5' value: [literal: '5']]
        * symbol: 'ALPHANUMERIC' literal: 'b' value: [symbol: 'LETTER' literal: 'b' value: [literal: 'b']]
        * symbol: 'ALPHANUMERIC' literal: 'v' value: [symbol: 'LETTER' literal: 'v' value: [literal: 'v']]
        * symbol: 'ALPHANUMERIC' literal: '9' value: [symbol: 'NUMBER' literal: '9' value: [literal: '9']]
        * symbol: 'ALPHANUMERIC' literal: '8' value: [symbol: 'NUMBER' literal: '8' value: [literal: '8']]
        * symbol: 'ALPHANUMERIC' literal: 'z' value: [symbol: 'LETTER' literal: 'z' value: [literal: 'z']]
        * literal: '}'

    verif gram, "{a5bv98z}", expected, it
