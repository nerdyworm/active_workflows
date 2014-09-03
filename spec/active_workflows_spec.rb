require_relative '../lib/active_workflows'

class Sayer < ActiveWorkflows::Activity
  def shout(name)
    puts name.upcase
    name.upcase
  end

  active_activity :shout, version: '1'
end

class Nom < ActiveWorkflows::Activity
  def execute(name)
    logger.error name
    puts "NOM NOM NOM: #{name}"
  end

  active_activity :execute, version: '1'
end

class Workflow < ActiveWorkflows::Workflow
  activity_client(:sayer) do
    { from_class: Sayer }
  end

  def start(options)
    sayer.shout(options.fetch("name"))
  end

  active_workflow :start
end

class D < ActiveWorkflows::Workflow
  activity_client(:sayer) do
    { from_class: Sayer }
  end

  activity_client(:nom) do
    { from_class: Nom }
  end

  def d(options)
    something = sayer.shout(options.fetch("name"))
    nom.execute(something)
  end

  active_workflow :d

  def task_list
    "private_task_list_2"
  end
end


describe "ActiveWorkflows" do
  it "works" do
    workflow = Workflow.new

    active = ActiveWorkflows.workflow(workflow)
    active.add_common_activity(Sayer.new)
    active.test({name: "Ben"})
  end

  it "runs many activities" do
    workflow = D.new

    active = ActiveWorkflows.workflow(workflow)
    active.add_common_activity(Sayer.new)
    active.add_common_activity(Nom.new)
    active.test({name: "ben"})
  end
end
