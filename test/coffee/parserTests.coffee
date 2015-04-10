requirejs = require 'requirejs'
assert = require 'assert'
fs = require 'fs'

requirejs.config
  nodeRequire: require
  baseUrl: __dirname + '/../../js'
  paths: require('../../requirejs-paths.json')

describe 'Parser unity', (done) ->
  parsers = null

  before (done) ->
    requirejs ['droplet-coffee','droplet-javascript'], (coffee_module, js_module) ->
      parsers =
        coffee: new coffee_module()
        js: new js_module()
      done()

  testAnyString = (lang, str) ->
    it 'should round-trip ' + str.split('\n')[0] +
        (if str.split('\n').length > 1 then '...' else ''), ->
      assert.equal str, parsers[lang].parse(str, wrapAtRoot: true).stringify()

  testAnyFile = (lang, name) ->
    it "should round-trip on #{name}", ->
      file = fs.readFileSync(name).toString()

      unparsed = parsers[lang].parse(file, wrapAtRoot: true).stringify()

      filelines = file.split '\n'
      for line, i in unparsed.split '\n'
        assert.equal line, filelines[i], "#{i} failed"

  describe "JavaScript", ->
    testString = testAnyString.bind(null, 'js')

    testString 'fd(10)'
    testString 'new X()'

  describe "CoffeeScript", ->
    testString = testAnyString.bind(null, 'coffee')
    testFile = testAnyFile.bind(null, "coffee")

    testString '/// #{x} ///'
    testString 'fd 10'
    testString 'fd 10 + 10'
    testString 'console.log 10 + 10'
    testString '''
    for i in [1..10]
      console.log 10 + 10
    '''
    testString '''
    array = []
    if a is b
      while p is q
        make spaghetti
        eat spaghetti
        array.push spaghetti
      for i in [1..10]
        console.log 10 + 10
    else
      see 'hi'
      for key, value in window
        see key + ' is ' + value
        see key is value
        see array[n]
    '''

    testFile 'test/data/nodes.coffee'
    testFile 'test/data/allTests.coffee'
