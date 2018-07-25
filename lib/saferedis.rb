class SafeRedis < Redis
  def initialize(**args)
    @killswitch = args[:killswitch] ||= :systems_redis_killswitch_customers
    super(**args)
  end

  DEFAULT_REDIS_UNAVAILABLE_RESPONSES = {
    :del =>           0,
    :exists =>        0,
    :expire =>        0,
    :get =>           nil,
    :hdel =>          0,
    :hget =>          nil, 
    :hgetall =>       [],
    :hkeys =>         [],
    :hincrby =>       1,
    :hlen =>          0,
    :hmget =>         [],
    :hmset =>         "",
    :hscan =>         [],
    :hset =>          false,
    :incr =>          false,
    :lpop =>          nil,
    :lpush =>         0, 
    :mapped_hmget =>  [], 
    :mapped_hmset =>  [],
    :ping =>          nil,
    :rename =>        "OK",
    :rpop =>          nil,
    :rpush =>         0, 
    :sadd =>          0, 
    :set =>           false, 
    :setex =>         "OK",
    :sismember =>     0,
    :smembers =>      [],
    :srem =>          0,
    :zadd =>          0,
    :zrange =>        [],
    :zrangebyscore => [],
    :zrem =>          0,
    :zremrangebyscore => 0, 
  }
  
  DEFAULT_REDIS_UNAVAILABLE_RESPONSES.keys.each do |method|
    define_method(method) do |*args|
      begin
        if Instacart.flipper[@killswitch].enabled?
          Rails.logger.info "-------------Aborting Redis call on Killswitch: #{@killswitch} ------"
          Rollbar.warn("Kill Switch on for #{@killswitch}. Returning default value for #{method}: #{DEFAULT_REDIS_UNAVAILABLE_RESPONSES[method]}") if defined?(Rollbar)
          return DEFAULT_REDIS_UNAVAILABLE_RESPONSES[method]
        else
          super(*args)
        end
      rescue => exception
        Rollbar.error("The connection to redis failed", exception) if defined?(Rollbar)
        raise "Failure Connecting to Redis" if Instacart.flipper[@killswitch].enabled?
        Rails.logger.info "------------- REDIS FAILURE -----------"
        DEFAULT_REDIS_UNAVAILABLE_RESPONSES[method]
      end
    end
  end

  def killswitch_enabled?
    
  end


  def pipelined
    return nil unless connection_available?
    super
  end

  def multi
    return nil unless connection_available?
    super
  end

  def connection_available?
    self.ping == "PONG"
  end

end

