path = require 'path'
{spawn} = require 'child_process'
Q = require 'q'

JasmineHandler = require '../../lib/handlers/jasmine-handler'

describe 'JasmineHandler', ->

  handler = undefined
  mockExecData = undefined
  noop = ->

  class FakeJasmineHandler extends JasmineHandler
    constructor: (@reportFile, @status) ->

    _spawnCommand: (defer) ->
      sourceReport = path.join(path.dirname(module.filename), '..', 'fixtures', 'junit-reports', @reportFile)
      spawn 'cp', ['-v', sourceReport, @getReportPath()]

  beforeEach ->
    atom.project.setPaths(['/Users/someuser/Projects/atom/testoscope/dummy'])

  describe 'successful test run', ->
    it 'returns the results', ->
      result = undefined

      handler = new FakeJasmineHandler('success.xml', 0)
      handler.run('successful-test')
        .then (r) ->
          result = r

      waitsFor ->
        result isnt undefined
      runs ->
        expect(result.wasSuccessful()).toBeTruthy()

  describe 'tests failed', ->
    it 'returns the results', ->
      output = ''
      result = undefined

      handler = new FakeJasmineHandler('fail.xml', 1)
      handler.run('failing-test')
        .then (r) ->
          result = r
        .progress (data) ->
          output = output + data

      waitsFor ->
        result isnt undefined
      runs ->
        expect(output).toMatch(/fail\.xml -> .*fail\.xml/)
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
      output = ''
      rejected = false

      handler = new FakeJasmineHandler('not_existent.xml', 0)
      handler.run('error')
        .progress (data) ->
          output = output + data
        .catch ->
          rejected = true

      waitsFor ->
        rejected
      runs ->
        expect(output).toMatch(/cp: [^\s]*not_existent.xml: No such file or directory/)

  describe 'has no report file', ->
    it 'returns the shell output', ->
      rejected = false
      output = ''

      handler = new FakeJasmineHandler('not_existent.xml', 1)
      handler.run('error')
        .progress (data) ->
          output = output + data
        .catch ->
          rejected = true

      waitsFor ->
        rejected
      runs ->
        expect(output).toMatch(/cp: [^\s]*not_existent.xml: No such file or directory/)
