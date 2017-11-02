noflo = require 'noflo'
FD = require 'fdjs'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Create a Finite Domain solving space'
  c.inPorts.add 'start',
    datatype: 'bang'
  c.outPorts.add 'space',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'start'
    input.getData 'start'
    output.sendDone
      space: new FD.space
