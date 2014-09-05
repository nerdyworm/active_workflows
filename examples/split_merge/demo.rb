require_relative 'workflow'

workflow = SplitMergeWorkflow.activate
workflow.add_common_activity(SplitMergeActivity)

ActiveWorkflows.execute do
  workflow.activity_loop
end
ActiveWorkflows.execute do
  workflow.decision_loop
end

things = []
1000.times do |i|
  things << i
end

workflow.run({things: things})

ActiveWorkflows.wait
