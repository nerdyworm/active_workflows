module ActiveWorkflows
  class Activator
    attr_reader :domain,
      :workflow_tasklist,
      :activity_tasklist,
      :host_activity_task_list

    def initialize(workflow)
      @workflow = workflow
      #@logger = ActiveWorkflows.logger

      swf = AWS::SimpleWorkflow.new

      domain = swf.domains[@workflow.domain_name]
      swf.domains.create(@workflow.domain_name, 10) unless domain.exists?

      @domain = domain
    end

    def workflow
      worker = AWS::Flow::WorkflowWorker.new(domain.client, domain, @workflow.task_list, @workflow.class) do
        {logger: @logger}
      end
      worker
    end

    def workflow_client
      AWS::Flow::workflow_client(domain.client, domain) do
        { from_class: @workflow.class, task_list: @workflow.task_list, logger: @logger }
      end
    end

    def run(input)
      workflow_client.start_execution(input.to_json)
    end

    # Executes the workflow in a simple loop
    def test(input)
      workflow.register
      common_activity_worker.register

      workflow_execution = run(input)

      last_event = ''
      while last_event != 'WorkflowExecutionCompleted' && last_event != 'WorkflowExecutionFailed' do
        event_types = workflow_execution.events.map(&:event_type)
        last_event = event_types.last
        if 'DecisionTaskScheduled' == last_event
          workflow.run_once
        elsif 'ActivityTaskScheduled' == last_event
          common_activity_worker.run_once
        end
      end
    end

    def common_activity_worker
      if @common_activity_worker.nil?
        worker = AWS::Flow::ActivityWorker.new(domain.client, domain, @workflow.activity_task_list) do
          {logger: @logger}
        end
        @common_activity_worker = worker
      end

      @common_activity_worker
    end

    def host_activity_worker
      if @host_activity_worker.nil?
        worker = AWS::Flow::ActivityWorker.new(domain.client, domain, @workflow.host_activity_task_list) do
          {logger: @logger}
        end
        @host_activity_worker = worker
      end

      @host_activity_worker
    end

    def decision_loop
      workflow.start
    end

    def activity_loop
      common_activity_worker.start(true)
    end

    def host_activity_loop
      host_activity_worker.start(true)
    end

    def add_common_activity(activity)
      common_activity_worker.add_implementation(activity)
    end

    def add_host_activity(activity)
      host_activity_worker.add_implementation(activity)
    end
  end
end
