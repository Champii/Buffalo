global import require \prelude-ls

test = it
require! {
  assert
  async
  \../src/parse-file
}

verif = (gram, str, expected, done) ->
  buff = new Buffer str
  parseFile buff, gram, (err, res) ->
    return done err if err?

    res.mapReplace!
    res.filterOptional!
    res.map ->
      delete it.parent
      it

    if JSON.stringify(res) !== JSON.stringify(expected)

      return done new Error 'Unexpected result\n' + JSON.stringify(res) + ' \nExpected\n' + JSON.stringify expected

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
      children:
        * symbol: ''
          literal: 'a'
          children: []
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
      children:
        * symbol: ''
          literal: 'a'
          children: []
        * symbol: ''
          literal: 'b'
          children: []

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
      children:
        * symbol: ''
          literal: 'ab'
          children: []
        * symbol: ''
          literal: 'cd'
          children: []

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
      children:
        * symbol: 'LETTER'
          literal: 'a'
          children:
            * symbol: ''
              literal: 'a'
              children: []
              ...
        * symbol: 'NUMBER'
          literal: '0'
          children:
            * symbol: ''
              literal: '0'
              children: []
              ...

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
      children: [symbol: '' literal: 'b' children: []]

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
      children:
        * symbol: 'LETTER' literal: 'a' children: [symbol: '' literal: 'a' children: []]
        * symbol: 'LETTER' literal: 'b' children: [symbol: '' literal: 'b' children: []]
        * symbol: 'LETTER' literal: 'c' children: [symbol: '' literal: 'c' children: []]
        * symbol: 'LETTER' literal: 'z' children: [symbol: '' literal: 'z' children: []]

    expected2 =
      symbol: 'S'
      literal: '487'
      children:
        * symbol: 'NUMBER' literal: '4' children: [symbol: '' literal: '4' children: []]
        * symbol: 'NUMBER' literal: '8' children: [symbol: '' literal: '8' children: []]
        * symbol: 'NUMBER' literal: '7' children: [symbol: '' literal: '7' children: []]

    expected3 =
      symbol: 'S'
      literal: '4s8a'
      children:
        * symbol: 'NUMBER' literal: '4' children: [symbol: '' literal: '4' children: []]
        * symbol: 'ALPHANUMERIC' literal: 's' children: [symbol: 'LETTER' literal: 's' children: [symbol: '' literal: 's' children: []]]
        * symbol: 'ALPHANUMERIC' literal: '8' children: [symbol: 'NUMBER' literal: '8' children: [symbol: '' literal: '8' children: []]]
        * symbol: 'ALPHANUMERIC' literal: 'a' children: [symbol: 'LETTER' literal: 'a' children: [symbol: '' literal: 'a' children: []]]

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
      children:
        * symbol: '' literal: 'a' children: []
        * symbol: '' literal: 'b' children: []
        * symbol: '' literal: 'c' children: []


    expected2 =
      symbol: 'S'
      literal: 'ac'
      children:
        * symbol: '' literal: 'a' children: []
        * symbol: '' literal: 'c' children: []

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
      children:
        * symbol: '' literal: 'a' children: []
        * symbol: '' literal: 'c' children: []

    expected2 =
      symbol: 'S'
      literal: 'abc'
      children:
        * symbol: '' literal: 'a' children: []
        * symbol: '' literal: 'b' children: []
        * symbol: '' literal: 'c' children: []

    expected3 =
      symbol: 'S'
      literal: 'abbbbbc'
      children:
        * symbol: '' literal: 'a' children: []
        * symbol: '' literal: 'b' children: []
        * symbol: '' literal: 'b' children: []
        * symbol: '' literal: 'b' children: []
        * symbol: '' literal: 'b' children: []
        * symbol: '' literal: 'b' children: []
        * symbol: '' literal: 'c' children: []

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
      children: []

    expected2 =
      symbol: 'S'
      literal: 'a'
      children:
        * symbol: '' literal: 'a' children: []
        ...

    expected3 =
      symbol: 'S'
      literal: 'b'
      children:
        * symbol: '' literal: 'b' children: []
        ...

    expected4 =
      symbol: 'S'
      literal: 'c'
      children:
        * symbol: '' literal: 'c' children: []
        ...
    expected5 =
      symbol: 'S'
      literal: 'ab'
      children:
        * symbol: '' literal: 'a' children: []
        * symbol: '' literal: 'b' children: []

    expected6 =
      symbol: 'S'
      literal: 'ac'
      children:
        * symbol: '' literal: 'a' children: []
        * symbol: '' literal: 'c' children: []

    expected7 =
      symbol: 'S'
      literal: 'abc'
      children:
        * symbol: '' literal: 'a' children: []
        * symbol: '' literal: 'b' children: []
        * symbol: '' literal: 'c' children: []

    expected8 =
      symbol: 'S'
      literal: 'aacc'
      children:
        * symbol: '' literal: 'a' children: []
        * symbol: '' literal: 'a' children: []
        * symbol: '' literal: 'c' children: []
        * symbol: '' literal: 'c' children: []

    expected9 =
      symbol: 'S'
      literal: 'bbcc'
      children:
        * symbol: '' literal: 'b' children: []
        * symbol: '' literal: 'b' children: []
        * symbol: '' literal: 'c' children: []
        * symbol: '' literal: 'c' children: []

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
      children:
        * symbol: '' literal: 'a' children: []
        * symbol: '' literal: 'b' children: []
        * symbol: '' literal: 'c' children: []

    expected3 =
      symbol: 'S'
      literal: 'abbbbbc'
      children:
        * symbol: '' literal: 'a' children: []
        * symbol: '' literal: 'b' children: []
        * symbol: '' literal: 'b' children: []
        * symbol: '' literal: 'b' children: []
        * symbol: '' literal: 'b' children: []
        * symbol: '' literal: 'b' children: []
        * symbol: '' literal: 'c' children: []

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
      children:
        * symbol: '' literal: '{' children: []
        * symbol: 'ALPHANUMERIC' literal: 'a' children: [symbol: 'LETTER' literal: 'a' children: [symbol: '' literal: 'a' children: []]]
        * symbol: 'ALPHANUMERIC' literal: '5' children: [symbol: 'NUMBER' literal: '5' children: [symbol: '' literal: '5' children: []]]
        * symbol: 'ALPHANUMERIC' literal: 'b' children: [symbol: 'LETTER' literal: 'b' children: [symbol: '' literal: 'b' children: []]]
        * symbol: 'ALPHANUMERIC' literal: 'v' children: [symbol: 'LETTER' literal: 'v' children: [symbol: '' literal: 'v' children: []]]
        * symbol: 'ALPHANUMERIC' literal: '9' children: [symbol: 'NUMBER' literal: '9' children: [symbol: '' literal: '9' children: []]]
        * symbol: 'ALPHANUMERIC' literal: '8' children: [symbol: 'NUMBER' literal: '8' children: [symbol: '' literal: '8' children: []]]
        * symbol: 'ALPHANUMERIC' literal: 'z' children: [symbol: 'LETTER' literal: 'z' children: [symbol: '' literal: 'z' children: []]]
        * symbol: '' literal: '}' children: []

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
      children:
        * symbol: '' literal: '{' children: []
        * symbol: 'ALPHANUMERIC' literal: 'a' children: [symbol: 'LETTER' literal: 'a' children: [symbol: '' literal: 'a' children: []]]
        * symbol: 'ALPHANUMERIC' literal: '5' children: [symbol: 'NUMBER' literal: '5' children: [symbol: '' literal: '5' children: []]]
        * symbol: 'ALPHANUMERIC' literal: 'b' children: [symbol: 'LETTER' literal: 'b' children: [symbol: '' literal: 'b' children: []]]
        * symbol: 'ALPHANUMERIC' literal: 'v' children: [symbol: 'LETTER' literal: 'v' children: [symbol: '' literal: 'v' children: []]]
        * symbol: 'ALPHANUMERIC' literal: '9' children: [symbol: 'NUMBER' literal: '9' children: [symbol: '' literal: '9' children: []]]
        * symbol: 'ALPHANUMERIC' literal: '8' children: [symbol: 'NUMBER' literal: '8' children: [symbol: '' literal: '8' children: []]]
        * symbol: 'ALPHANUMERIC' literal: 'z' children: [symbol: 'LETTER' literal: 'z' children: [symbol: '' literal: 'z' children: []]]
        * symbol: '' literal: '}' children: []

    verif gram, "{a5bv98z}", expected, it
