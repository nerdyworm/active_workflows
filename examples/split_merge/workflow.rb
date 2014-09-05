require 'active_workflows'
require 'pp'

class SplitMergeActivity < ActiveWorkflows::Activity
  def print_things(things)
    things.each do |thing|
      puts thing
    end

    things
  end

  active_activity :print_things
end

class SplitMergeWorkflow < ActiveWorkflows::Workflow
  activity_client(:client) do
    { from_class: 'SplitMergeActivity' }
  end

  def average(options)
    results = []

    things = options.fetch('things')

    things.each_slice(100).to_a.each do |smaller_things|
      results << client.send_async(:print_things, smaller_things)
    end

    update_state "waiting for #{results.size} results"
    wait_for_all(results)

    update_state "got all results"
    results.each do |result|
      pp results
    end
  end

  active_workflow :average
end
