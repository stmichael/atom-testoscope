path = require 'path'

RspecHandler = require '../../lib/handlers/rspec-handler'

describe 'RspecHandler', ->

  handler = undefined
  mockExecData = undefined
  noop = ->

  class FakeRspecHandler extends RspecHandler
    constructor: (@reportFile, options) ->
      super(options)

    _getBashCommand: (testFilePath) ->
      "cp #{path.join(path.dirname(module.filename), '..', 'fixtures', 'rspec-reports', @reportFile)} #{@getReportPath()}"

  beforeEach ->
    atom.project.setPaths(['/Users/someuser/Projects/atom/testoscope/dummy'])

  describe 'configuration', ->
    it 'executes rspec', ->
      handler = new FakeRspecHandler('report.json', useBundler: false)
      expect(handler._getCommand('test.rb', 'some/path'))
        .toEqual('rspec --format json --out some/path/rspec.json test.rb')

    it 'executes rspec with bundler', ->
      handler = new FakeRspecHandler('report.json', useBundler: true)
      expect(handler._getCommand('test.rb', 'some/path'))
        .toEqual('bundle exec rspec --format json --out some/path/rspec.json test.rb')

  describe 'report parsing', ->
    it 'the tests were successful', ->
      result = undefined
      callback = (r) ->
        result = r

      handler = new FakeRspecHandler('success.json')
      handler.run 'successful-test', callback, noop

      waitsFor ->
        result isnt undefined
      runs ->
        expect(result.wasSuccessful()).toBeTruthy()


    it 'there were failures in the tests', ->
      result = undefined
      callback = (r) ->
        result = r

      handler = new FakeRspecHandler('fail.json')
      handler.run 'failing-test', callback, noop

      waitsFor ->
        result isnt undefined
      runs ->
        expect(result.wasSuccessful()).toBeFalsy()
        expect(result.getFailures().length).toEqual 1
        failure = result.getFailures()[0]
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
