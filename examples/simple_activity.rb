require 'active_workflows'

class Shouter < ActiveWorkflows::Activity
  def shout(name)
    10.times do
      puts name.upcase
    end
  end

  active_activity :shout, version: '2'
end

class SimpleWorkflow < ActiveWorkflows::Workflow
  activity_client(:shouter) do
    { from_class: Shouter }
  end

  def simple_activity_workflow(options)
    shouter.shout(options.fetch("name"))
  end

  active_workflow :simple_activity_workflow, version: '2'
end

workflow = SimpleWorkflow.new
active = ActiveWorkflows.activate(workflow)
active.add_common_activity(Shouter.new)
active.test({name: "Ben"})
