Stacktrace = require './stacktrace'
TestSuiteResult = require './test-suite-result'

module.exports =
class RspecReportParser

  parse: (data) ->
    result = new TestSuiteResult
    reportObject = JSON.parse(data)
    for example in reportObject.examples
      if example.status == 'failed'
        stacktrace = new Stacktrace(@_parseStacktrace(example.exception.backtrace))
        result.addFailure
          namespace: example.full_description.replace(new RegExp(" #{example.description}"), '')
          name: example.description
          messages: example.exception.message.split("\n")
          file: example.file_path
          line: example.line_number.toString()
          fullStacktrace: stacktrace.getFullTrace()
          stacktrace: stacktrace.getRelevantTrace()
      else
        result.addSuccess
          namespace: example.full_description.replace(new RegExp(" #{example.description}"), '')
          name: example.description

    result

  _parseStacktrace: (stacktrace) ->
    for line in stacktrace
      matchData = line.match(/((\/[^\/:]+)+):(\d+).*`(.+)'/)
      caller: matchData[4]
      file: matchData[1]
      line: matchData[3]
