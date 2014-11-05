xpath = require('xpath')
{DOMParser} = require('xmldom')
Entities = require('html-entities').AllHtmlEntities;
Stacktrace = require './stacktrace'
TestSuiteResult = require './test-suite-result'

module.exports =
class JunitReportParser
  parse: (data) ->
    result = new TestSuiteResult
    doc = new DOMParser().parseFromString(data)
    failures = xpath.select('(//failure)', doc)
    for failure in failures
      stacktraceTexts = @_buildArrayedStacktrace(xpath.select('./text()', failure)[0].nodeValue)
      stacktrace = new Stacktrace(@_parseStacktrace(stacktraceTexts))

      result.addFailure
        namespace: failure.parentNode.getAttribute('classname')
        name: failure.parentNode.getAttribute('name')
        messages: @_extractFailureMessages(xpath.select('./text()', failure)[0].nodeValue)
        file: atom.project.relativize(stacktrace.getTestCaller().file)
        line: stacktrace.getTestCaller().line
        fullStacktrace: stacktrace.getFullTrace()
        stacktrace: stacktrace.getRelevantTrace()

    result

  _buildArrayedStacktrace: (stacktrace) ->
    entities = new Entities
    result = entities.decode(stacktrace).split("\n")
    result = (line.replace(/^\s+/g, '') for line in result)
    result.filter (line) ->
      line.length > 0 && line.match(/(\/[^\/]+)+/)

  _parseStacktrace: (stacktraceText) ->
    for line in stacktraceText
      matchData = line.match(/at (.*) \(((\/[^\/:]+)+):(\d+)/)
      caller: matchData[1]
      file: matchData[2]
      line: matchData[4]

  _extractFailureMessages: (stacktrace) ->
    entities = new Entities
    stacktraceLines = entities.decode(stacktrace).split("\n")
      .filter (line) ->
        line.length > 0
    [stacktraceLines[0].replace(/^\s+/g, '')]
