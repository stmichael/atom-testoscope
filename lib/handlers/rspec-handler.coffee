path = require 'path'
fs = require 'fs.extra'
BaseHandler = require './base-handler'
RspecReportParser = require '../report-parsers/rspec-report-parser'

module.exports =
class RspecHandler extends BaseHandler

  constructor: (options) ->
    super
    options = options || {}
    @useBundler = options.useBundler

  _getCommand: (testFilePath, reportPath) ->
    if @useBundler
      "bundle exec rspec --format json --out #{path.join(reportPath, 'rspec.json')} #{testFilePath}"
    else
      "rspec --format json --out #{path.join(reportPath, 'rspec.json')} #{testFilePath}"

  parseErrors: (successCallback, errorCallback, error, stdout, stderr) ->
    file = path.join(@getReportPath(), 'rspec.json')
    if fs.existsSync(file)
      fs.readFile file, encoding: 'UTF-8', (err, data) =>
        if data.match(/^\s*$/)
          errorCallback(stdout)
        else
          result = new RspecReportParser().parse(data)
          successCallback(result)
    else
      errorCallback(stderr)
