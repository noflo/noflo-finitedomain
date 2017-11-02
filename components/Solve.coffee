noflo = require 'noflo'
FD = require 'fdjs'

exports.getComponent = ->
  c = new noflo.Component
  c.description = 'Solve a Finite Domain solving space'
  c.inPorts.add 'space',
    datatype: 'object'
  c.inPorts.add 'variables',
    datatype: 'array'
  c.inPorts.add 'distribution',
    datatype: 'string'
    control: true
    default: 'fail_first'
  c.inPorts.add 'search',
    datatype: 'string'
    control: true
    default: 'depth_first'
  c.outPorts.add 'solution',
    datatype: 'object'
  c.outPorts.add 'error',
    datatype: 'object'
  c.process (input, output) ->
    return unless input.hasData 'space', 'variables'
    return if input.attached('distribution').length and not input.hasData 'distribution'
    return if input.attached('search').length and not input.hasData 'search'
    [space, variables] = input.getData 'space', 'variables'
    if typeof variables is 'string'
      variables = variables.split ','
    distribution = 'fail_first'
    if input.hasData 'distribution'
      distribution = input.getData 'distribution'
    unless FD.distribute[distribution]
      output.done new Error "Finite Domain distribution strategy #{distribution} not found"
      return
    search = 'depth_first'
    if input.hasData 'search'
      search = input.getData 'search'
    unless FD.search[search]
      output.done new Error "Finite Domain search strategy #{search} not found"
      return
    FD.distribute[distribution] space, variables

    step = (state) ->
      FD.search[search] state
      if state.space.is_solved()
        output.send
          solution: state.space.solution()
      if state.more
        # Next solving round
        setTimeout ->
          step state
        , 0
        return
      # We've sent all the solutions out
      output.send
        solution: new noflo.IP 'closeBracket'
      output.done()

    initialState =
      space: space
      more: yes
    output.send
      solution: new noflo.IP 'openBracket'
    step initialState
