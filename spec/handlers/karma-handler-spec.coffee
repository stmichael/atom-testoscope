path = require 'path'
fs = require 'fs'

KarmaHandler = require '../../lib/handlers/karma-handler'

describe 'KarmaHandler', ->

  handler = undefined
  mockExecData = undefined
  noop = ->

  class FakeKarmaHandler extends KarmaHandler
    _getBashCommand: (testFilePath) ->
      "cp #{path.join(path.dirname(module.filename), '..', 'fixtures', 'junit-reports', 'fail.xml')} #{path.join(@getReportPath(), 'test-results.xml')} && exit 1"

  beforeEach ->
    atom.project.setPaths(['/Users/someuser/Projects/atom/test-runner/dummy'])

  describe 'configuration', ->
    it 'run karma with a configuration file', ->
      handler = new FakeKarmaHandler(config: 'karma.js')
      expect(handler._getCommand('test.js', 'some/path'))
        .toMatch(/^node_modules\/karma\/bin\/karma start karma\.js --single-run --reporters junit && cp test-results\.xml .+/)

  describe 'report parsing', ->
    beforeEach ->
      handler = new FakeKarmaHandler

    it 'parses the junit report', ->
      failingTests = undefined
      errorCallback = (errors) ->
        failingTests = errors

      handler.run 'failing-test', noop, errorCallback

      waitsFor ->
        failingTests != undefined
      runs ->
        expect(failingTests.length).toEqual 1
        failingTest = failingTests[0]
        expect(failingTest.namespace).toEqual 'jasmine test suite'
        expect(failingTest.name).toEqual 'a failing test',
        expect(failingTest.message).toEqual 'Error: Expected true to equal false.',
        expect(failingTest.file).toEqual 'spec/fixtures/fail_spec.js',
        expect(failingTest.line).toEqual '6'
        expect(failingTest.stacktrace).toEqual [
          {caller: 'null.<anonymous>', file: '/Users/someuser/Projects/atom/test-runner/spec/fixtures/fail_spec.js', line: '6'}
        ]

    it 'deletes the test report after parsing', ->
      failingTests = undefined
      errorCallback = (errors) ->
        failingTests = errors

      handler.run 'failing-test', noop, errorCallback

      waitsFor ->
        failingTests != undefined
      runs ->
        expect(fs.existsSync(path.join(atom.project.getPaths()[0], 'test-results.xml'))).toBeFalsy()
