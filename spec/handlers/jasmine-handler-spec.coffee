path = require 'path'

JasmineHandler = require '../../lib/handlers/jasmine-handler'

describe 'JasmineHandler', ->

  handler = undefined
  mockExecData = undefined
  noop = ->

  class FakeJasmineHandler extends JasmineHandler
    constructor: (@reportFile, @status) ->

    _getBashCommand: (testFilePath) ->
      "cp #{path.join(path.dirname(module.filename), '..', 'fixtures', 'junit-reports', @reportFile)} #{@getReportPath()}; echo 'done'; exit #{@status}"

  beforeEach ->
    atom.project.setPaths(['/Users/someuser/Projects/atom/testoscope/dummy'])

  describe 'successful test run', ->
    it 'returns the results', ->
      result = undefined
      callback = (r) ->
        result = r

      handler = new FakeJasmineHandler('success.xml', 0)
      handler.run 'successful-test', callback, noop

      waitsFor ->
        result isnt undefined
      runs ->
        expect(result.wasSuccessful()).toBeTruthy()

  describe 'tests failed', ->
    it 'returns the results', ->
      result = undefined
      callback = (r) ->
        result = r

      handler = new FakeJasmineHandler('fail.xml', 1)
      handler.run 'failing-test', callback, noop

      waitsFor ->
        result isnt undefined
      runs ->
        expect(result.wasSuccessful()).toBeFalsy()
        expect(result.getTestcases().length).toEqual 1
        failure = result.getTestcases()[0]
        expect(failure.namespace).toEqual 'jasmine test suite'
        expect(failure.name).toEqual 'a failing test',
        expect(failure.messages).toEqual ['Error: Expected true to equal false.'],
        expect(failure.file).toEqual 'spec/fixtures/fail_spec.js',
        expect(failure.line).toEqual '6'
        expect(failure.stacktrace).toEqual [
          {caller: 'null.<anonymous>', file: '/Users/someuser/Projects/atom/testoscope/spec/fixtures/fail_spec.js', line: '6'}
        ]

  describe 'test command failed due to syntax errors', ->
    it 'returns the shell output', ->
      output = undefined
      callback = (o) ->
        output = o

      handler = new FakeJasmineHandler('not_existent.xml', 0)
      handler.run 'error', (->), callback

      waitsFor ->
        output isnt undefined
      runs ->
        expect(output).toMatch(/^\s*done\s*$/)

  describe 'has no report file', ->
    it 'returns the shell output', ->
      output = undefined
      callback = (o) ->
        output = o

      handler = new FakeJasmineHandler('not_existent.xml', 1)
      handler.run 'error', (->), callback

      waitsFor ->
        output isnt undefined
      runs ->
        expect(output).toMatch(/^\s*done\s*$/)
