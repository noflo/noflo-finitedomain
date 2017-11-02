noflo = require 'noflo'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Declare a variable into a Finite Domain solving space'
  c.inPorts.add 'space',
    datatype: 'object'
  c.inPorts.add 'variable',
    datatype: 'string'
  c.inPorts.add 'domain',
    datatype: 'array'
  c.outPorts.add 'space',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'space', 'variable', 'domain'
    [space, variable, domain] = input.getData 'space', 'variable', 'domain'
    if typeof domain is 'string'
      domain = JSON.parse domain
    space.decl variable, domain
    output.sendDone
      space: space
