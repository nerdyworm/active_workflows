module ActiveWorkflows
  class Handler
    def handle(method, input)
      exception_handler do
        options = parse_input(input)
        method[options]
      end
    end

    def parse_input(input)
      JSON.parse(input)
    end

    def exception_handler
      begin
        yield
      rescue => e
        ActiveWorkflows.exception_reporter.report(e)
        raise e
      end
    end

    def logger
      ActiveWorkflows.logger
    end
  end

  class Workflow
    extend AWS::Flow::Workflows

    def self.active_workflow(method, options={})
      workflow(method) do
        {
          version: '1',
          execution_start_to_close_timeout: 60 * 10,
        }.merge(options)
      end

      handler = self.handler
      m = instance_method(method)
      define_method method do |input|
        handler.handle(m.bind(self), input)
      end
    end

    def self.handler
      ActiveWorkflows::Handler.new
    end

    def self.activate
      ActiveWorkflows.activate(new)
    end

    attr_accessor :host_activity_task_list
    attr_reader :state

    get_state_method(:state)

    def initialize
      @host_activity_task_list = "#{activity_task_list}_#{Socket.gethostname}"
    end

    def update_state(new_state)
      logger.info "#{display_name} #{state} => #{new_state} run_id=#{run_id} " unless replaying?
      @state = new_state
    end

    def display_name
      self.class.to_s
    end

    def domain_name
      "workflows_test"
    end

    def task_list
      "workflow_task_list"
    end

    def activity_task_list
      "task_list"
    end

    def replaying?
      decision_context.workflow_clock.replaying
    end

    def logger
      ActiveWorkflows.logger
    end
  end
end
