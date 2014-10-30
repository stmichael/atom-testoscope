require '../spec-helper'
path = require 'path'

RspecHandler = require '../../lib/handlers/rspec-handler'

describe 'RspecHandler', ->

  handler = undefined
  mockExecData = undefined
  noop = ->

  class FakeRspecHandler extends RspecHandler
    getReportPath: ->
      path.join(path.dirname(module.filename), '..', 'fixtures', 'rspec-reports')

    cleanReportPath: ->

  beforeEach ->
    handler = new FakeRspecHandler
    mockExecData = mockExec()
    atom.project.setPaths(['/Users/someuser/Projects/atom/test-runner'])

  afterEach ->
    resetExec(mockExecData)

  it 'parses the json report', ->
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
