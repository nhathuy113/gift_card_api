class JwtService
  ALGORITHM = "HS256".freeze
  TTL = 1.hour

  def self.encode(user)
    payload = { user_id: user.id, role: user.role, jti: SecureRandom.uuid, exp: TTL.from_now.to_i }
    JWT.encode(payload, secret, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, secret, true, algorithm: ALGORITHM).first
    decoded.with_indifferent_access
  rescue JWT::DecodeError
    nil
  end

  def self.secret = Rails.application.secret_key_base
end
