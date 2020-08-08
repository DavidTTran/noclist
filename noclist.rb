require 'Faraday'
require 'digest'

class Noclist
  def initialize
    @token = get_token
    @checksum = get_checksum
    @ids = get_user_ids
  end

  def display_ids
    return nil if @ids == nil
    p @ids
  end

  private

  def connection(path = nil)
    Faraday.new("http://localhost:8888/#{path}")
  end

  def get_token(attempts = 0)
    return nil if attempts == 3
    response = connection("auth").get
    return response.headers["badsec-authentication-token"] if response.status == 200
    get_token(attempts += 1)
  end

  def get_user_ids(attempts = 0)
    return nil if attempts == 3 || @checksum == nil
    response = connection("users").get do |request|
      request.headers["X-Request-Checksum"] = @checksum
    end
    return response.body.split("\n") if response.status == 200
    get_user_ids(attempts += 1)
  end

  def get_checksum
    @token ? Digest::SHA2.hexdigest("#{@token}/users") : nil
  end
end
