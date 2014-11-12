path = require 'path'
{spawn} = require 'child_process'

RspecHandler = require '../../lib/handlers/rspec-handler'

describe 'RspecHandler', ->

  class FakeRspecHandler extends RspecHandler
    constructor: (@reportFile, options) ->
      super(options)

    _spawnCommand: ->
      sourceReport = path.join(path.dirname(module.filename), '..', 'fixtures', 'rspec-reports', @reportFile)
      spawn 'cp', ['-v', sourceReport, path.join(@getReportPath(), 'rspec.json')]

  beforeEach ->
    atom.project.setPaths(['/Users/someuser/Projects/atom/testoscope/dummy'])

  describe 'configuration', ->
    it 'executes rspec', ->
      handler = new FakeRspecHandler('report.json', useBundler: false)
      expect(handler._getCommand())
        .toEqual('rspec')
      expect(handler._getCommandArgs('test.rb', 'some/path'))
        .toEqual(['--format', 'progress', '--format', 'json', '--out', 'some/path/rspec.json', 'test.rb'])

    it 'executes rspec with bundler', ->
      handler = new FakeRspecHandler('report.json', useBundler: true)
      expect(handler._getCommand())
        .toEqual('bundle')
      expect(handler._getCommandArgs('test.rb', 'some/path'))
        .toEqual(['exec', 'rspec', '--format', 'progress', '--format', 'json', '--out', 'some/path/rspec.json', 'test.rb'])

  describe 'successful test run', ->
    it 'returns the results', ->
      result = undefined
      callback = (r) ->
        result = r

      handler = new FakeRspecHandler('success.json')
      handler.run('successful-test')
        .then(callback)

      waitsFor ->
        result isnt undefined
      runs ->
        expect(result.wasSuccessful()).toBeTruthy()

  describe 'tests failed', ->
    it 'returns the results', ->
      output = ''
      result = undefined
      callback = (r) ->
        result = r

      handler = new FakeRspecHandler('fail.json')
      handler.run('failing-test')
        .then callback
        .progress (data) ->
          output = output + data

      waitsFor ->
        result isnt undefined
      runs ->
        expect(output).toMatch(/\.json -> .*\.json/)
        expect(result.wasSuccessful()).toBeFalsy()
        expect(result.getTestcases().length).toEqual 1
        failure = result.getTestcases()[0]
        expect(failure.namespace).toEqual 'ErrorsPresenter nested errors'
        expect(failure.name).toEqual 'exports nested errors',
        expect(failure.messages).toEqual ["undefined method `injfect' for {:questions=\u003e[#\u003cRSpec::Mocks::Mock:0x3fcf34f0bd7c @name=nil\u003e]}:Hash"],
        expect(failure.file).toEqual './spec/unit/presenters/errors_presenter_spec.rb',
        expect(failure.line).toEqual '32'
        expect(failure.stacktrace).toEqual [
          {file: "/Users/someuser/Projects/atom/testoscope/app/presenters/errors_presenter.rb", line: "15", caller: "fields_as_json"}
          {file: "/Users/someuser/Projects/atom/testoscope/app/presenters/errors_presenter.rb", line: "10", caller: "as_json"}
          {file: "/Users/someuser/Projects/atom/testoscope/spec/unit/presenters/errors_presenter_spec.rb", line: "33", caller: "block (3 levels) in \u003ctop (required)\u003e"}
        ]

  describe 'test command failed due to syntax errors', ->
    it 'returns the shell output', ->
      output = ''
      rejected = false

      handler = new FakeRspecHandler('not_existent.json')
      handler.run('error')
        .progress (data) ->
          output = output + data
        .catch ->
          rejected = true

      waitsFor ->
        rejected && output.length > 0
      runs ->
        expect(output).toMatch(/not_existent\.json: No such file or directory/)

  describe 'has no report file', ->
    it 'returns the shell output', ->
      output = ''
      rejected = false

      handler = new FakeRspecHandler('not_existent.json')
      handler.run('error')
        .progress (data) ->
          output = output + data
        .catch ->
          rejected = true

      waitsFor ->
        rejected
      runs ->
        expect(output).toMatch(/not_existent\.json: No such file or directory/)
