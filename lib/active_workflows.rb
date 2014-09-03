require 'aws/decider'
require 'aws/flow'


module ActiveWorkflows
  require "active_workflows/version"
  require 'active_workflows/activator'
  require 'active_workflows/workflow'
  require 'active_workflows/activity'

  def self.workflow(workflow)
    Activator.new(workflow)
  end

  def self.activate(workflow)
    Activator.new(workflow)
  end

  def self.logger
    if @logger.nil?
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::INFO
    end

    @logger
  end

  def self.logger=(logger)
    @logger = logger
  end

  def self.exception_reporter
    ExceptionReporter.new
  end

  def self.activity_handler
    @activity_handler ||= ActivityHandler.new
  end

  def self.workflow_handler
    @workflow_handler ||= WorkflowHandler.new
  end

  def self.child_processes
    @child_proccesses ||=[]
  end

  def self.execute
    pid = fork do
      yield
    end

    ActiveWorkflows.child_processes << pid
  end

  def self.wait
    Signal.trap('TERM') { graceful_exit 'QUIT' }
    Signal.trap('INT')  { graceful_exit 'INT'  }
    Process.waitall
  end

  def self.graceful_exit(s)
    ActiveWorkflows.child_processes.each do |child|
      Process.kill(s, child)
    end

    exit(0)
  end

  class ExceptionReporter
    def report(e)
      ActiveWorkflows.logger.error("#{e}\n"+e.backtrace.join("\n"))
    end
  end
end
