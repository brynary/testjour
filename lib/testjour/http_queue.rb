require "testjour/core_extensions/wait_for_service"
require "redis"

module Testjour

  class RedisQueue

    def self.reset_all
      redis.del "testjour:feature_files"
      redis.del "testjour:results"
    end

    def self.redis
      @redis ||= Redis.new(:db => 11)
    end

    def redis
      self.class.redis
    end

    def push(queue_name, data)
      redis.lpush("testjour:#{queue_name}", Marshal.dump(data))
    end

    def pop(queue_name)
      result = redis.rpop("testjour:#{queue_name}")
      result ? Marshal.load(result) : nil
    end

  end

end