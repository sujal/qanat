require 'em-jack'

module Qanat
  class Beanstalk
    def initialize(config, queue)
      @server = EMJack::Connection.new(config)
      @server.fiber!
      @queue = queue
      @timeout = queue.config[:timeout] || config[:timeout] || 5
    end

    def process_loop
      @processor ||= @queue.processor_class.new
      while true
        job = @server.reserve # ignore timeout for now, blocking should be ok
        @processor.process(job)
        job.delete
      end
    end
  end
end