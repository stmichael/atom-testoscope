module.exports =
class RspecReportParser

  parse: (data) ->
    reportObject = JSON.parse(data)
    result = []
    for example in reportObject.examples
      if example.status == 'failed'
        result.push
          namespace: example.full_description.replace(new RegExp(" #{example.description}"), '')
          name: example.description
          message: example.exception.message
          file: example.file_path
          line: example.line_number.toString()
          fullStacktrace: example.exception.backtrace
          stacktrace: @_extractRelevantLines(example.exception.backtrace)

    result

  _extractRelevantLines: (stacktrace) ->
    blacklistRegex = new RegExp('/lib/')
    whitelistRegex = new RegExp(atom.project.getPaths()[0].replace(/\//g, '\\/'))
    stacktrace.filter (line) ->
      line.match(whitelistRegex) && !line.match(blacklistRegex)
