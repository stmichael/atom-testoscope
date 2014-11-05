path = require 'path'
fs = require 'fs'

KarmaHandler = require '../../lib/handlers/karma-handler'

describe 'KarmaHandler', ->

  handler = undefined
  mockExecData = undefined
  noop = ->

  class FakeKarmaHandler extends KarmaHandler
    constructor: (@reportFile, options) ->
      super(options)

    _getBashCommand: (testFilePath) ->
      "cp #{path.join(path.dirname(module.filename), '..', 'fixtures', 'junit-reports', @reportFile)} #{path.join(@getReportPath(), 'test-results.xml')}"

  beforeEach ->
    atom.project.setPaths(['/Users/someuser/Projects/atom/test-runner/dummy'])

  describe 'configuration', ->
    it 'run karma with a configuration file', ->
      handler = new FakeKarmaHandler('report.xml', config: 'karma.js')
      expect(handler._getCommand('test.js', 'some/path'))
        .toMatch(/^node_modules\/karma\/bin\/karma start karma\.js --single-run --reporters junit; mv .*test-results\.xml .+/)

  describe 'report parsing', ->
    it 'the tests were successful', ->
      result = undefined
      callback = (r) ->
        result = r

      handler = new FakeKarmaHandler('success.xml')
      handler.run 'successful-test', callback, noop

      waitsFor ->
        result isnt undefined
      runs ->
        expect(result.wasSuccessful()).toBeTruthy()

    it 'there were failures in the tests', ->
      result = undefined
      callback = (r) ->
        result = r

      handler = new FakeKarmaHandler('fail.xml')
      handler.run 'failing-test', callback, noop

      waitsFor ->
        result isnt undefined
      runs ->
        expect(result.wasSuccessful()).toBeFalsy()
        expect(result.getFailures().length).toEqual 1
        failure = result.getFailures()[0]
        expect(failure.namespace).toEqual 'jasmine test suite'
        expect(failure.name).toEqual 'a failing test',
        expect(failure.message).toEqual 'Error: Expected true to equal false.',
        expect(failure.file).toEqual 'spec/fixtures/fail_spec.js',
        expect(failure.line).toEqual '6'
        expect(failure.stacktrace).toEqual [
          {caller: 'null.<anonymous>', file: '/Users/someuser/Projects/atom/test-runner/spec/fixtures/fail_spec.js', line: '6'}
        ]
