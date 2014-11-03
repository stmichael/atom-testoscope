require '../spec-helper'
path = require 'path'

KarmaHandler = require '../../lib/handlers/karma-handler'

describe 'KarmaHandler', ->

  handler = undefined
  mockExecData = undefined
  noop = ->

  class FakeKarmaHandler extends KarmaHandler
    getReportPath: ->
      path.join(path.dirname(module.filename), '..', 'fixtures', 'junit-reports')

    cleanReportPath: ->

  beforeEach ->
    mockExecData = mockExec()

  afterEach ->
    resetExec(mockExecData)

  describe 'configuration', ->
    it 'run karma with a configuration file', ->
      handler = new FakeKarmaHandler(config: 'karma.js')
      expect(handler.getCommand('test.js', 'some/path'))
        .toEqual('node_modules/karma/bin/karma start karma.js --single-run --reporters junit')

  describe 'report parsing', ->
    beforeEach ->
      handler = new FakeKarmaHandler

    it 'parses the junit report', ->
      failingTests = undefined
      errorCallback = (errors) ->
        failingTests = errors

      handler.run 'failing-test', noop, errorCallback
      mockExecData.callback(1)

      waitsFor ->
        failingTests != undefined
      runs ->
        expect(failingTests.length).toEqual 1
        failingTest = failingTests[0]
        expect(failingTest.namespace).toEqual 'jasmine test suite'
        expect(failingTest.name).toEqual 'a failing test',
        expect(failingTest.message).toEqual 'Error: Expected true to equal false.',
        expect(failingTest.file).toEqual 'fail_spec.js',
        expect(failingTest.line).toEqual '6'
        expect(failingTest.stacktrace).toEqual [
          {caller: 'null.<anonymous>', file: '/Users/stmichael/Projects/atom/test-runner/spec/fixtures/fail_spec.js', line: '6'}
        ]
