require 'active_workflows'

class Shouter < ActiveWorkflows::Activity
  def shout(name)
    10.times do
      puts name.upcase
    end

    name.upcase
  end

  active_activity :shout, version: '2'
end

class ShoutBack < ActiveWorkflows::Activity
  def shout(name)
    puts "#{name.upcase} shhhhhhh!"
  end

  active_activity :shout
end

class SimpleWorkflow < ActiveWorkflows::Workflow
  activity_client(:shouter) do
    { from_class: Shouter }
  end

  activity_client(:shout_back) do
    { from_class: ShoutBack }
  end

  def simple_activity_workflow(options)
    name = shouter.shout(options.fetch("name"))
    shout_back.shout(name)
  end

  active_workflow :simple_activity_workflow, version: '2'
end

workflow = SimpleWorkflow.new
active = ActiveWorkflows.activate(workflow)
active.add_common_activity(Shouter.new)
active.add_common_activity(ShoutBack.new)
active.test({name: "Ben"})
