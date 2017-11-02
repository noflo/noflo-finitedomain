noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Declare that a variable must be greater than another variable'
  c.inPorts.add 'space',
    datatype: 'object'
  c.inPorts.add 'greater',
    datatype: 'string'
  c.inPorts.add 'than',
    datatype: 'string'
  c.outPorts.add 'space',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'space', 'greater', 'than'
    [space, greater, than] = input.getData 'space', 'greater', 'than'
    space.gt greater, than
    output.sendDone
      space: space
