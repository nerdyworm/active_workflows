require 'active_workflows'

class Shouter < ActiveWorkflows::Activity
  activity :shout do
    {
      version: '11',
      default_task_list: 'task_list',
      default_task_schedule_to_start_timeout: 30,
      default_task_start_to_close_timeout: 120,
    }
  end

  def execute(name)
    puts name.upcase
  end
end

class SimpleWorkflow < ActiveWorkflows::Workflow
  workflow  :simple_workflow do
    {
      version: '3',
      execution_start_to_close_timeout: 60 * 10,
    }
  end

  activity_client(:shouter) do
    { from_class: 'Shouter' }
  end

  def simple_workflow(options)
    shouter.shout(options.fetch("name"))
  end

  active_workflow_method :simple_workflow
end

active = SimpleWorkflow.activate
active.add_common_activity(Shouter.new)

ActiveWorkflows.execute do
  active.activity_loop
end
ActiveWorkflows.execute do
  active.decision_loop
end
ActiveWorkflows.execute do
  count = 0
  while true
    count += 1
    active.run({name: "Hello #{ count }"})
    sleep 5
  end
end

ActiveWorkflows.wait
