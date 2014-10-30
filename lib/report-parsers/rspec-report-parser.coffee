Stacktrace = require './stacktrace'

module.exports =
class RspecReportParser

  parse: (data) ->
    reportObject = JSON.parse(data)
    result = []
    for example in reportObject.examples
      if example.status == 'failed'
        stacktrace = new Stacktrace(@_parseStacktrace(example.exception.backtrace))
        result.push
          namespace: example.full_description.replace(new RegExp(" #{example.description}"), '')
          name: example.description
          message: example.exception.message
          file: example.file_path
          line: example.line_number.toString()
          fullStacktrace: stacktrace.getFullTrace()
          stacktrace: stacktrace.getRelevantTrace()

    result

  _parseStacktrace: (stacktrace) ->
    for line in stacktrace
      matchData = line.match(/((\/[^\/:]+)+):(\d+).*`(.+)'/)
      caller: matchData[4]
      file: matchData[1]
      line: matchData[3]
