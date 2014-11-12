path = require 'path'
fs = require 'fs'
{spawn} = require 'child_process'

KarmaHandler = require '../../lib/handlers/karma-handler'

describe 'KarmaHandler', ->

  class FakeKarmaHandler extends KarmaHandler
    constructor: (@reportFile, options) ->
      super(options)

    _spawnCommand: (defer) ->
      sourceReport = path.join(path.dirname(module.filename), '..', 'fixtures', 'junit-reports', @reportFile)
      spawn 'cp', ['-v', sourceReport, @getReportPath()]

  beforeEach ->
    atom.project.setPaths(['/Users/someuser/Projects/atom/testoscope/dummy'])

  describe 'configuration', ->
    it 'run karma with a configuration file', ->
      handler = new FakeKarmaHandler('report.xml', config: 'karma.js')
      expect(handler._getCommand())
        .toEqual('node_modules/karma/bin/karma')
      expect(handler._getCommandArgs('test.js', 'some/path'))
        .toEqual(['start', 'karma.js', '--single-run', '--reporters', 'junit,dots'])

  describe 'successful test run', ->
    it 'returns the results', ->
      result = undefined

      handler = new FakeKarmaHandler('success.xml')
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

      handler = new FakeKarmaHandler('fail.xml')
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

      handler = new FakeKarmaHandler('empty.xml')
      handler.run('error')
        .progress (data) ->
          output = output + data
        .catch ->
          rejected = true

      waitsFor ->
        rejected
      runs ->
        expect(output).toMatch(/empty\.xml -> .*empty\.xml/)

  describe 'has no report file', ->
    it 'returns the shell output', ->
      output = ''
      rejected = false

      handler = new FakeKarmaHandler('not_existent.xml')
      handler.run('error')
        .progress (data) ->
          output = output + data
        .catch ->
          rejected = true

      waitsFor ->
        rejected
      runs ->
        expect(output).toMatch(/not_existent\.xml: No such file or directory/)
