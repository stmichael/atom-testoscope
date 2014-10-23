RspecReportParser = require '../../lib/report-parsers/rspec-report-parser'

describe 'JunitReportParser', ->

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
    results = parser.parse(report)

    expect(results.length).toEqual 1
    result = results[0]
    expect(result.namespace).toEqual 'ErrorsPresenter nested errors'
    expect(result.name).toEqual 'exports nested errors',
    expect(result.message).toEqual "undefined method `injfect' for {:questions=\u003e[#\u003cRSpec::Mocks::Mock:0x3fcf34f0bd7c @name=nil\u003e]}:Hash",
    expect(result.file).toEqual './spec/unit/presenters/errors_presenter_spec.rb',
    expect(result.line).toEqual '32'
    expect(result.stacktrace).toEqual [
      "/Users/someuser/Projects/atom/test-runner/app/presenters/errors_presenter.rb:15:in `fields_as_json'",
      "/Users/someuser/Projects/atom/test-runner/app/presenters/errors_presenter.rb:10:in `as_json'",
      "/Users/someuser/Projects/atom/test-runner/spec/unit/presenters/errors_presenter_spec.rb:33:in `block (3 levels) in \u003ctop (required)\u003e'",
    ]
    expect(result.fullStacktrace).toEqual [
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
