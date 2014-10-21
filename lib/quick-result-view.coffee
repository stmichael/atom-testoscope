{View} = require 'atom'

module.exports =
class QuickResultView extends View
  @content: ->
    @div is: 'status-bar-quick-test-result', class: 'quick-test-result inline-block', =>
      @span ''
    #   @div "The TestRunner package is Alive! It's ALIVE!", class: "message"

  setRunning: ->
    @find('span').removeClass()
      .addClass('icon icon-clock status-running')
      .text('running')

  setSuccessful: (filepath) ->
    @find('span').removeClass()
      .addClass('icon icon-check status-successful')
      .text("All tests in #{filepath} have been successful")

  setFaulty: (filepath) ->
    @find('span').removeClass()
      .addClass('icon icon-stop status-erroneous')
      .text("The tests in #{filepath} were faulty")

  destroy: ->
    @detach()
