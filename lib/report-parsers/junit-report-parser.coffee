xpath = require('xpath')
{DOMParser} = require('xmldom')
Entities = require('html-entities').AllHtmlEntities;
Stacktrace = require './stacktrace'

module.exports =
class JunitReportParser
  parse: (data) ->
    doc = new DOMParser().parseFromString(data)
    failures = xpath.select('(//failure)', doc)
    for failure in failures
      stacktraceTexts = @_buildArrayedStacktrace(xpath.select('./text()', failure)[0].nodeValue)
      stacktrace = new Stacktrace(@_parseStacktrace(stacktraceTexts))

      namespace: failure.parentNode.getAttribute('classname')
      name: failure.parentNode.getAttribute('name')
      message: @_extractFailureMessage(xpath.select('./text()', failure)[0].nodeValue)
      file: atom.project.relativize(stacktrace.getTestCaller().file)
      line: stacktrace.getTestCaller().line
      fullStacktrace: stacktrace.getFullTrace()
      stacktrace: stacktrace.getRelevantTrace()

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

  _extractFailureMessage: (stacktrace) ->
    entities = new Entities
    entities.decode(stacktrace).split("\n")[0]
      .replace(/^\s+/g, '')
