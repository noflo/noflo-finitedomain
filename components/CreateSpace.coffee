noflo = require 'noflo'
FD = require 'fdjs'

class CreateSpace extends noflo.Component
  constructor: ->
    @inPorts =
      start: new noflo.Port 'bang'
    @outPorts =
      space: new noflo.Port 'object'

    @inPorts.start.on 'data', =>
      @outPorts.space.send new FD.space
      @outPorts.space.disconnect()

exports.getComponent = -> new CreateSpace
