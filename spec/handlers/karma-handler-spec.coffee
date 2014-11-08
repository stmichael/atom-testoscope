path = require 'path'
fs = require 'fs'

KarmaHandler = require '../../lib/handlers/karma-handler'

describe 'KarmaHandler', ->

  handler = undefined
  mockExecData = undefined
  noop = ->

  class FakeKarmaHandler extends KarmaHandler
    constructor: (@reportFile, @status, options) ->
      super(options)

    _getBashCommand: (testFilePath) ->
      "cp #{path.join(path.dirname(module.filename), '..', 'fixtures', 'junit-reports', @reportFile)} #{path.join(@getReportPath(), 'test-results.xml')}; echo 'done'; exit #{@status}"

  beforeEach ->
    atom.project.setPaths(['/Users/someuser/Projects/atom/testoscope/dummy'])

  describe 'configuration', ->
    it 'run karma with a configuration file', ->
      handler = new FakeKarmaHandler('report.xml', 0, config: 'karma.js')
      expect(handler._getCommand('test.js', 'some/path'))
        .toMatch(/^node_modules\/karma\/bin\/karma start karma\.js --single-run --reporters junit,dots; mv .*test-results\.xml .+/)

  describe 'successful test run', ->
    it 'returns the results', ->
      result = undefined
      callback = (r) ->
        result = r

      handler = new FakeKarmaHandler('success.xml', 0)
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

      handler = new FakeKarmaHandler('fail.xml', 1)
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

      handler = new FakeKarmaHandler('empty.xml', 1)
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

      handler = new FakeKarmaHandler('not_existent.xml', 1)
      handler.run 'error', (->), callback

      waitsFor ->
        output isnt undefined
      runs ->
        expect(output).toMatch(/not_existent\.xml: No such file or directory/)
