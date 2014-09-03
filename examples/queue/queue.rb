require 'active_workflows'

class Worker1 < ActiveWorkflows::Activity
  def perform(options)
    name = options.fetch("name")
    10.times do
      puts "WORKER1: #{name.upcase}"
    end
  end

  active_activity :perform, version: '2'
end

class Worker2 < ActiveWorkflows::Activity
  def perform(options)
    name = options.fetch("name")
    10.times do
      puts "WORKER2: #{name.upcase}"
    end

    name.upcase
  end

  active_activity :perform, version: '2'
end

class SimpleWorkflowQueue < ActiveWorkflows::Workflow
  def run(options)
    from_class = options.fetch("worker_name")

    self.class.activity_client :performer do
      { from_class: from_class }
    end

    update_state("Performing #{from_class}")

    begin
      performer.perform(options)
    rescue => e
      update_state("Failed: #{e.message}")
      raise e
    end

    update_state("Complete")
  end

  active_workflow :run, version: '1'
end
