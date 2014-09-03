require_relative 'queue'

class SomeStrangeWorker < ActiveWorkflows::Activity
  def perform(options)
    puts "DOING ALL THE STRANGE KIND OF THINGS"
  end
  active_activity :perform
end

active = SimpleWorkflowQueue.activate
active.add_common_activity(Worker1.new)
active.add_common_activity(Worker2.new)
active.add_common_activity(SomeStrangeWorker.new)

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
    active.run({worker_name: "Worker1", name: "do something #{count}"})
    sleep 1
    active.run({worker_name: "Worker2", name: "do more things #{count}"})
    sleep 1
    active.run({worker_name: "SomeStrangeWorker", name: "more strange things #{count}"})
    sleep 1
  end
end

ActiveWorkflows.wait
