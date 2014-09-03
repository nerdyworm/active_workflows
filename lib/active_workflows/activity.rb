module ActiveWorkflows
  class Activity
    extend AWS::Flow::Activities

    def self.active_activity(method, options={})
      activity method do
        {
          version: '1',
          default_task_list: 'task_list',
          default_task_schedule_to_start_timeout: 30,
          default_task_start_to_close_timeout: 120,
        }.merge(options)
      end

      handler = self.handler
      m = instance_method(method)
      define_method method do |input|
        handler.handle(m.bind(self), input)
      end
    end

    def self.handler
      ActiveWorkflows::ActivityHandler.new
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

  class ActivityHandler
    def handle(method, input)
      exception_handler do
        method[input]
      end
    end

    def exception_handler
      begin
        yield
      rescue => e
        ActiveWorkflows.exception_reporter.report(e)
        raise e
      end
    end
  end
end
