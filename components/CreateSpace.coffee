noflo = require 'noflo'
FD = require 'fdjs'

class CreateSpace extends noflo.Component
  constructor: ->
    @inPorts =
      in: new noflo.Port 'bang'
    @outPorts =
      out: new noflo.Port 'object'

    @inPorts.in.on 'data', =>
      @outPorts.out.send new FD.space
      @outPorts.out.disconnect()

exports.getComponent = -> new CreateSpace
