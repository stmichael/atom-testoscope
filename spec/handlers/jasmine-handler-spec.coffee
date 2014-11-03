require '../spec-helper'
path = require 'path'

JasmineHandler = require '../../lib/handlers/jasmine-handler'

describe 'JasmineHandler', ->

  handler = undefined
  mockExecData = undefined
  noop = ->

  class FakeJasmineHandler extends JasmineHandler
    getReportPath: ->
      path.join(path.dirname(module.filename), '..', 'fixtures', 'junit-reports')

    cleanReportPath: ->

  beforeEach ->
    handler = new FakeJasmineHandler
    mockExecData = mockExec()

  afterEach ->
    resetExec(mockExecData)

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
