require "testjour/core_extensions/wait_for_service"
require "redis"

module Testjour

  class RedisQueue

    def self.reset_all
      local_redis.del "testjour:feature_files"
      local_redis.del "testjour:results"
    end

    def self.local_redis
      @redis ||= Redis.new(:db => 11)
    end
    
    def initialize(redis_host)
      @redis = Redis.new(:db => 11, :host => redis_host)
    end
    
    attr_reader :redis

    def push(queue_name, data)
      redis.lpush("testjour:#{queue_name}", Marshal.dump(data))
    end

    def pop(queue_name)
      result = redis.rpop("testjour:#{queue_name}")
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

  end

end