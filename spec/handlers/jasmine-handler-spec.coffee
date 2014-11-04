path = require 'path'

JasmineHandler = require '../../lib/handlers/jasmine-handler'

describe 'JasmineHandler', ->

  handler = undefined
  mockExecData = undefined
  noop = ->

  class FakeJasmineHandler extends JasmineHandler
    _getBashCommand: (testFilePath) ->
      "cp #{path.join(path.dirname(module.filename), '..', 'fixtures', 'junit-reports', 'fail.xml')} #{@getReportPath()} && exit 1"

  beforeEach ->
    atom.project.setPaths(['/Users/someuser/Projects/atom/test-runner/dummy'])
    handler = new FakeJasmineHandler

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
