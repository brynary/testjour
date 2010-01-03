require "testjour/core_extensions/wait_for_service"
require "redis"

module Testjour

  class RedisQueue
    
    def initialize(redis_host, queue_namespace)
      @redis = Redis.new(:db => 11, :host => redis_host)
      @queue_namespace = queue_namespace
    end
    
    attr_reader :redis

    def push(queue_name, data)
      redis.lpush("testjour:#{queue_namespace}:#{queue_name}", Marshal.dump(data))
    end

    def pop(queue_name)
      result = redis.rpop("testjour:#{queue_namespace}:#{queue_name}")
      result ? Marshal.load(result) : nil
    end

    def blocking_pop(queue_name)
      Timeout.timeout(180) do
        result = nil

        while result.nil?
          result = pop(queue_name)
          sleep 0.1 unless result
        end

        result
      end
    end
   
    def reset_all
      redis.del "testjour:#{queue_namespace}:feature_files"
      redis.del "testjour:#{queue_namespace}:results"
    end
    
 protected
    
    def queue_namespace
      @queue_namespace
    end

  end

end