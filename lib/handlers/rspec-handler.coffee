path = require 'path'
fs = require 'fs.extra'
BaseHandler = require './base-handler'
RspecReportParser = require '../report-parsers/rspec-report-parser'

module.exports =
class RspecHandler extends BaseHandler

  constructor: (options) ->
    super
    @options = options || {}

  _getCommand: (testFilePath, reportPath) ->
    if @options.invocation == 'rbenv'
      'bash'
    else
      "rspec"

  _getCommandArgs: (testFilePath, reportPath) ->
    if @options.invocation == 'rbenv'
      ['-l', '-c', "eval \"$(rbenv init - bash)\" && bundle exec rspec --format progress --format json --out #{path.join(reportPath, 'rspec.json')} #{testFilePath}"]
    else
      ['--format', 'progress', '--format', 'json', '--out', path.join(reportPath, 'rspec.json'), testFilePath]

  parseErrors: (defer) ->
    fs.readdir @getReportPath(), (err, files) =>
      if files.length > 0
        file = path.join(@getReportPath(), 'rspec.json')
        fs.readFile file, encoding: 'UTF-8', (err, data) =>
          if data.match(/^\s*$/)
            defer.reject()
          else
            result = new RspecReportParser().parse(data)
            defer.resolve result
      else
        defer.reject()
