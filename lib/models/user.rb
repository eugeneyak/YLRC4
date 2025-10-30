class User < Sequel::Model
  def full_name
    "#{first_name} #{last_name}".strip
  end
end
