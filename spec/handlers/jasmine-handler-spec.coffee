path = require 'path'

JasmineHandler = require '../../lib/handlers/jasmine-handler'

describe 'JasmineHandler', ->

  handler = undefined
  mockExecData = undefined
  noop = ->

  class FakeJasmineHandler extends JasmineHandler
    constructor: (@reportFile) ->

    _getBashCommand: (testFilePath) ->
      "cp #{path.join(path.dirname(module.filename), '..', 'fixtures', 'junit-reports', @reportFile)} #{@getReportPath()}"

  beforeEach ->
    atom.project.setPaths(['/Users/someuser/Projects/atom/testoscope/dummy'])

  it 'the tests were successful', ->
    result = undefined
    callback = (r) ->
      result = r

    handler = new FakeJasmineHandler('success.xml')
    handler.run 'successful-test', callback, noop

    waitsFor ->
      result isnt undefined
    runs ->
      expect(result.wasSuccessful()).toBeTruthy()

  it 'there were failures in the tests', ->
    result = undefined
    callback = (r) ->
      result = r

    handler = new FakeJasmineHandler('fail.xml')
    handler.run 'failing-test', callback, noop

    waitsFor ->
      result isnt undefined
    runs ->
      expect(result.wasSuccessful()).toBeFalsy()
      expect(result.getFailures().length).toEqual 1
      failure = result.getFailures()[0]
      expect(failure.namespace).toEqual 'jasmine test suite'
      expect(failure.name).toEqual 'a failing test',
      expect(failure.messages).toEqual ['Error: Expected true to equal false.'],
      expect(failure.file).toEqual 'spec/fixtures/fail_spec.js',
      expect(failure.line).toEqual '6'
      expect(failure.stacktrace).toEqual [
        {caller: 'null.<anonymous>', file: '/Users/someuser/Projects/atom/testoscope/spec/fixtures/fail_spec.js', line: '6'}
      ]
