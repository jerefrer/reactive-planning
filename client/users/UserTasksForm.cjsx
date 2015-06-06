Tasks = new Meteor.Collection('tasks')
DragDropMixin = ReactDND.DragDropMixin
ItemTypes = TASK: 'task'

@UserTasksForm = React.createClass
  mixins: [ ReactMeteor.Mixin ]
  startMeteorSubscriptions: ->
    Meteor.subscribe 'users'
    Meteor.subscribe 'tasks'
  getMeteorState: ->
    user: Meteor.users.findOne(@props.userId)
    tasks: Tasks.find().fetch()
  render: ->
    <ReactBootstrap.ModalTrigger modal={<UserTasksModal user={@state.user} tasks={@state.tasks} />}>
      <a className="btn btn-primary">Modifier ses rôles</a>
    </ReactBootstrap.ModalTrigger>

UserTasksModal = React.createClass
  render: ->
    <ReactBootstrap.Modal {...@props} bsStyle='primary' title="Rôles de #{@props.user.username}" animation>
      <div className='modal-body task-form'>
        <div className="row same-height-columns">
          <TaskList tasks={@props.tasks} user={@props.user} />
          <div className="divider"></div>
          <PreferedOrBannedTaskList user={@props.user} tasks={@props.user.preferedTasks} preferedOrBanned='Prefered' />
          <div className="divider"></div>
          <PreferedOrBannedTaskList user={@props.user} tasks={@props.user.bannedTasks}   preferedOrBanned='Banned' />
        </div>
      </div>
      <div className='modal-footer'>
        <ReactBootstrap.Button onClick={@props.onRequestHide}>Fermer</ReactBootstrap.Button>
      </div>
    </ReactBootstrap.Modal>

TaskList = React.createClass
  getInitialState: ->
    tasks: @props.tasks
  getRemainingTasks: (tasks) ->
    tasks.findAll (task) =>
      preferedTasksIds = (@props.user.preferedTasks || []).map('_id')
      bannedTasksIds   = (@props.user.bannedTasks || []).map('_id')
      preferedTasksIds.concat(bannedTasksIds).indexOf(task._id) < 0
  render: ->
    tasksList = @getRemainingTasks(@state.tasks).map (task) -> <Task task={task} />
    <div className="tasks-list col-md-4">
      <h3>Tâches</h3>
      <ul className="list-unstyled">{tasksList}</ul>
    </div>

TaskFilters = React.createClass
  handleChange: ->
    @props.onChange @refs.name.getDOMNode().value.trim()
  render: ->
    <div className="form-group form-inline">
      <label className="control-label">Nom</label>
      <input type="text" ref="name" onChange={@handleChange} className="form-control" />
    </div>

PreferedOrBannedTaskList = React.createClass
  prefered: ->
    @props.preferedOrBanned == 'Prefered'
  handleTaskDrop: (taskId, removeFromOtherList) ->
    Meteor.call "addUser#{@props.preferedOrBanned}Task", @props.user._id, taskId, removeFromOtherList
  removeTask: (taskId) ->
    Meteor.call "removeUser#{@props.preferedOrBanned}Task", @props.user._id, taskId
  mixins: [ DragDropMixin ]
  statics: configureDragDrop: (register) ->
    register ItemTypes.TASK, dropTarget:
      acceptDrop: (component, item) ->
        component.handleTaskDrop item.taskId, item.removeFromOtherList
  getRemainingTasks: (tasks) ->
    tasks.findAll (task) =>
      tasksToReject  = @prefered() && @props.user.bannedTasks || @props.user.preferedTasks
      (tasksToReject || []).map('_id').indexOf(task._id) < 0
  render: ->
    tasks = @getRemainingTasks(@props.tasks)
    tasksList = undefined
    if tasks
      tasksList = tasks.map (taskId) =>
        task = Tasks.findOne(taskId)
        <Task task={task} onThrowAway={@removeTask} inPreferedOrBannedList=true />
    dropState = @getDropState(ItemTypes.TASK)
    className = React.addons.classSet
      "prefered-tasks": @prefered()
      "banned-tasks": not @prefered()
      "col-md-4": true
      "drop-target": dropState.isDragging
      "drop-hover": dropState.isHovering
    <div {...@dropTargetFor(ItemTypes.TASK)} className={className}>
      <h3 className={@prefered() && 'text-success' || 'text-danger'}>{@prefered() && 'Souvent' || 'Jamais'}</h3>
      {tasksList}
    </div>

Task = React.createClass
  mixins: [ DragDropMixin ]
  statics: configureDragDrop: (register) ->
    register ItemTypes.TASK, dragSource:
      beginDrag: (component) ->
        item: { taskId: component.props.task._id, removeFromOtherList: component.props.inPreferedOrBannedList }
      endDrag: (component, effect) ->
        if !effect
          if component.props.onThrowAway
            component.props.onThrowAway component.props.task._id
  render: ->
    <div className="task alert alert-info"
        {...@dragSourceFor(ItemTypes.TASK)}>
      {@props.task.name}
    </div>
