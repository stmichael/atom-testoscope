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
        "/Users/someuser/Projects/atom/test-runner/app/presenters/errors_presenter.rb:15:in `fields_as_json'",
        "/Users/someuser/Projects/atom/test-runner/app/presenters/errors_presenter.rb:10:in `as_json'",
        "/Users/someuser/Projects/atom/test-runner/spec/unit/presenters/errors_presenter_spec.rb:33:in `block (3 levels) in \u003ctop (required)\u003e'",
      ]
      expect(failingTest.fullStacktrace).toEqual [
        "/Users/someuser/Projects/atom/test-runner/app/presenters/errors_presenter.rb:15:in `fields_as_json'",
        "/Users/someuser/Projects/atom/test-runner/app/presenters/errors_presenter.rb:10:in `as_json'",
        "/Users/someuser/Projects/atom/test-runner/spec/unit/presenters/errors_presenter_spec.rb:33:in `block (3 levels) in \u003ctop (required)\u003e'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example.rb:114:in `instance_eval'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example.rb:114:in `block in run'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example.rb:254:in `with_around_each_hooks'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example.rb:111:in `run'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example_group.rb:390:in `block in run_examples'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example_group.rb:386:in `map'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example_group.rb:386:in `run_examples'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example_group.rb:371:in `run'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example_group.rb:372:in `block in run'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example_group.rb:372:in `map'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example_group.rb:372:in `run'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/command_line.rb:28:in `block (2 levels) in run'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/command_line.rb:28:in `map'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/command_line.rb:28:in `block in run'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/reporter.rb:58:in `report'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/command_line.rb:25:in `run'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/runner.rb:80:in `run'",
        "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/runner.rb:17:in `block in autorun'"
      ]
