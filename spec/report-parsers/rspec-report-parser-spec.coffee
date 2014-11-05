RspecReportParser = require '../../lib/report-parsers/rspec-report-parser'

describe 'RspecReportParser', ->

  report = '''{
    "examples":[
      {
        "description":"exports nested errors",
        "full_description":"ErrorsPresenter nested errors exports nested errors",
        "status":"passed",
        "file_path":"./spec/unit/presenters/errors_presenter_spec.rb",
        "line_number":32
      },
      {
        "description":"exports nested errors",
        "full_description":"ErrorsPresenter nested errors exports nested errors",
        "status":"failed",
        "file_path":"./spec/unit/presenters/errors_presenter_spec.rb",
        "line_number":32,
        "exception":{
          "class":"NoMethodError",
          "message":"undefined method `injfect' for {:questions=\u003e[#\u003cRSpec::Mocks::Mock:0x3fcf34f0bd7c @name=nil\u003e]}:Hash",
          "backtrace":[
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
        }
      }
    ],
    "summary":{
      "duration":0.001401,
      "example_count":2,
      "failure_count":2,
      "pending_count":0
      },
      "summary_line":"2 examples, 2 failures"
    }
    '''

  beforeEach ->
    atom.project.setPaths(['/Users/someuser/Projects/atom/test-runner'])

  it 'converts an junit report into an object', ->
    parser = new RspecReportParser
    result = parser.parse(report)

    expect(result.wasSuccessful()).toBeFalsy()
    expect(result.getFailures().length).toEqual 1
    failure = result.getFailures()[0]
    expect(failure.namespace).toEqual 'ErrorsPresenter nested errors'
    expect(failure.name).toEqual 'exports nested errors',
    expect(failure.message).toEqual "undefined method `injfect' for {:questions=\u003e[#\u003cRSpec::Mocks::Mock:0x3fcf34f0bd7c @name=nil\u003e]}:Hash",
    expect(failure.file).toEqual './spec/unit/presenters/errors_presenter_spec.rb',
    expect(failure.line).toEqual '32'
    expect(failure.stacktrace).toEqual [
      {file: "/Users/someuser/Projects/atom/test-runner/app/presenters/errors_presenter.rb", line: "15", caller: "fields_as_json"}
      {file: "/Users/someuser/Projects/atom/test-runner/app/presenters/errors_presenter.rb", line: "10", caller: "as_json"}
      {file: "/Users/someuser/Projects/atom/test-runner/spec/unit/presenters/errors_presenter_spec.rb", line: "33", caller: "block (3 levels) in \u003ctop (required)\u003e"}
    ]
    expect(failure.fullStacktrace).toEqual [
      {file: "/Users/someuser/Projects/atom/test-runner/app/presenters/errors_presenter.rb", line: "15", caller: "fields_as_json"}
      {file: "/Users/someuser/Projects/atom/test-runner/app/presenters/errors_presenter.rb", line: "10", caller: "as_json"}
      {file: "/Users/someuser/Projects/atom/test-runner/spec/unit/presenters/errors_presenter_spec.rb", line: "33", caller: "block (3 levels) in \u003ctop (required)\u003e"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example.rb", line: "114", caller: "instance_eval"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example.rb", line: "114", caller: "block in run"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example.rb", line: "254", caller: "with_around_each_hooks"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example.rb", line: "111", caller: "run"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example_group.rb", line: "390", caller: "block in run_examples"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example_group.rb", line: "386", caller: "map"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example_group.rb", line: "386", caller: "run_examples"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example_group.rb", line: "371", caller: "run"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example_group.rb", line: "372", caller: "block in run"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example_group.rb", line: "372", caller: "map"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/example_group.rb", line: "372", caller: "run"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/command_line.rb", line: "28", caller: "block (2 levels) in run"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/command_line.rb", line: "28", caller: "map"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/command_line.rb", line: "28", caller: "block in run"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/reporter.rb", line: "58", caller: "report"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/command_line.rb", line: "25", caller: "run"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/runner.rb", line: "80", caller: "run"}
      {file: "/Users/someuser/.rvm/gems/ruby-2.0.0-p247@test-runner/gems/rspec-core-2.14.7/lib/rspec/core/runner.rb", line: "17", caller: "block in autorun"}
    ]
