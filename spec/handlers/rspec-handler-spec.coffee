path = require 'path'

RspecHandler = require '../../lib/handlers/rspec-handler'

describe 'RspecHandler', ->

  handler = undefined
  mockExecData = undefined
  noop = ->

  class FakeRspecHandler extends RspecHandler
    _getBashCommand: (testFilePath) ->
      "cp #{path.join(path.dirname(module.filename), '..', 'fixtures', 'rspec-reports', 'rspec.json')} #{@getReportPath()} && exit 1"

  beforeEach ->
    atom.project.setPaths(['/Users/someuser/Projects/atom/test-runner/dummy'])

  describe 'configuration', ->
    it 'executes rspec', ->
      handler = new FakeRspecHandler(useBundler: false)
      expect(handler._getCommand('test.rb', 'some/path'))
        .toEqual('rspec --format json --out some/path/rspec.json test.rb')

    it 'executes rspec with bundler', ->
      handler = new FakeRspecHandler(useBundler: true)
      expect(handler._getCommand('test.rb', 'some/path'))
        .toEqual('bundle exec rspec --format json --out some/path/rspec.json test.rb')

  describe 'report parsing', ->
    beforeEach ->
      handler = new FakeRspecHandler

    it 'parses the json report', ->
      failingTests = undefined
      errorCallback = (errors) ->
        failingTests = errors

      handler.run 'failing-test', noop, errorCallback

      waitsFor ->
        failingTests != undefined
      runs ->
        expect(failingTests.length).toEqual 1
        failingTest = failingTests[0]
        expect(failingTest.namespace).toEqual 'ErrorsPresenter nested errors'
        expect(failingTest.name).toEqual 'exports nested errors',
        expect(failingTest.message).toEqual "undefined method `injfect' for {:questions=\u003e[#\u003cRSpec::Mocks::Mock:0x3fcf34f0bd7c @name=nil\u003e]}:Hash",
        expect(failingTest.file).toEqual './spec/unit/presenters/errors_presenter_spec.rb',
        expect(failingTest.line).toEqual '32'
        expect(failingTest.stacktrace).toEqual [
          {file: "/Users/someuser/Projects/atom/test-runner/app/presenters/errors_presenter.rb", line: "15", caller: "fields_as_json"}
          {file: "/Users/someuser/Projects/atom/test-runner/app/presenters/errors_presenter.rb", line: "10", caller: "as_json"}
          {file: "/Users/someuser/Projects/atom/test-runner/spec/unit/presenters/errors_presenter_spec.rb", line: "33", caller: "block (3 levels) in \u003ctop (required)\u003e"}
        ]
