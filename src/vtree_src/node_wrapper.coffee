Vtree = require('vtree')
NodeData = require('vtree/node_data')

class NodeWrapper

  layoutId = 0
  COMPONENT_PATTERN = /(.+)#(.+)/
  SECRET_KEY = 'semarf'

  constructor: (@node) ->
    @$el = @node.$el
    @el = @node.el

    layoutId++ if @isLayout()
    @identifyNodeAttributes()
    @initNodeDataObject()

  identifyNodeAttributes: ->
    @layoutName = @layout().name
    @layoutId = @layout().id

    if @hasComponent()
      [@componentName, @nodeName] = Vtree.config().extractComponentData(@$el)
    else
      @componentName = @layoutName
      @nodeName = @nodeUnderscoredName()

  initNodeDataObject: ->
    @nodeData = @initNodeData()
    @_hooks()?.init?(@nodeData)

  initNodeData: ->
    if @hasComponent()
      componentNameUnderscored = @componentName
      componentName = @componentName.camelize()
      applicationNameUnderscored = null
      applicationName = null
    else
      applicationNameUnderscored = @componentName
      applicationName = @componentName.camelize()
      componentNameUnderscored = null
      componentName = null

    new NodeData({
      isApplicationLayout: @isLayout()
      isApplicationPart: not @hasComponent()
      isComponentPart: @hasComponent()
      applicationId: if not @hasComponent() then @layoutId else null

      nodeName: @nodeName
      applicationName,
      applicationNameUnderscored,
      componentName,
      componentNameUnderscored
    })

  unload: ->
    @_hooks()?.unload?(@nodeData)
    delete @nodeData
    delete @node

  hasComponent: ->
    @_hasComponent ||= Vtree.config().hasComponent(@$el)

  layout: ->
    @_layout ||=
      if @isLayout()
        {name: @layoutUnderscoredName(), id: layoutId}
      else if @node.parent?
        @node.parent.nodeWrapper.layout()
      else
        {name: SECRET_KEY, id: 0}


  # private

  isLayout: ->
    @_isLayout ?= Vtree.config().isLayout(@$el)

  layoutUnderscoredName: ->
    @_layoutUnderscoredName ?= Vtree.config().layoutUnderscoredName(@$el)

  nodeUnderscoredName: ->
    @_nodeUnderscoredName ?= Vtree.config().nodeUnderscoredName(@$el)

  _hooks: ->
    # @options.hooks

modula.export('vtree/node_wrapper', NodeWrapper)
