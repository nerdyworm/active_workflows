module ActiveWorkflows
  class Activity
    extend AWS::Flow::Activities

    def self.active_activity(method, options={})
      activity method do
        {
          version: '1.0.0',
          default_task_list: 'task_list',
          default_task_start_to_close_timeout:    60 * 10,
          default_task_schedule_to_start_timeout: 60 * 10,
          default_task_schedule_to_close_timeout: 60 * 10,
        }.merge(options)
      end

      handler = self.handler
      m = instance_method(method)
      define_method method do |*args|
        handler.handle(m.bind(self), *args)
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
    def handle(method, *args)
      exception_handler do
        method[*args]
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
