# frozen_string_literal: true

ActiveSupport::TestCase.class_eval do
  # when job execution is on jobs can end up in the queue and that can break future tests
  # so we clean after using JobExecution
  def with_job_execution
    JobExecution.enabled = true
    yield
  ensure
    JobExecution.clear_queue
    JobExecution.send(:job_queue).instance_variable_get(:@active).clear
    JobExecution.enabled = false
  end

  def self.with_job_execution
    around { |t| with_job_execution(&t) }
  end

  def self.with_job_stop_timeout(value)
    around do |test|
      begin
        old = JobExecution.stop_timeout
        JobExecution.stop_timeout = value
        test.call
      ensure
        JobExecution.stop_timeout = old
      end
    end
  end
end