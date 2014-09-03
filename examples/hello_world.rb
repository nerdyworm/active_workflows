require 'active_workflows'

class HelloWorkflow < ActiveWorkflows::Workflow
  workflow :start

  def start(options)
    puts "Hello, #{options["name"]}"
  end

  active_workflow_method :start
end

workflow = HelloWorkflow.new
active = ActiveWorkflows.workflow(workflow)
active.test({name: "Ben"})
