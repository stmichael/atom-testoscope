{View} = require 'atom'

module.exports =
class ResultStatusView extends View
  @content: ->
    @div class: 'test-result-status inline-block', =>
      @span ''

  setRunning: ->
    @find('span').removeClass()
      .addClass('icon icon-clock status-running')
      .text('running')

  setSuccessful: (message) ->
    @find('span').removeClass()
      .addClass('icon icon-check status-successful')
      .text(message)

  setFaulty: (message) ->
    @find('span').removeClass()
      .addClass('icon icon-stop status-erroneous')
      .text(message)

  destroy: ->
    @detach()
