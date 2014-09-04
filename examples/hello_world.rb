require 'active_workflows'

class HelloWorkflow < ActiveWorkflows::Workflow
  def start(options)
    puts "Hello, #{options["name"]}"
  end

  active_workflow :start, domain_name: "my-test-domain"
end

workflow = HelloWorkflow.new
active = ActiveWorkflows.workflow(workflow)
active.test({name: "Ben"})
