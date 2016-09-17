class User < ActiveRecord::Base
	attr_accessor :remember_token, :activation_token
	before_save :downcase_email
	before_create :create_activation_digest
	validates :name, presence: true, length: {maximum: 50}
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, length: {maximum: 255}, format: { with: VALID_EMAIL_REGEX },
	uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, presence: true, length: {minimum: 6}, allow_nil: true

	def User.digest(string)
		cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    	BCrypt::Password.create(string, cost: cost)

	end

#xay dung 1 method tao 1 token tu SecureRandom.urlsafe_base64 sau khi log on
	def User.new_token
		SecureRandom.urlsafe_base64
	end

#remember user
	def remember
		self.remember_token = User.new_token 	#gan remember_token = method da chuyen doi o tren
		update_attribute(:remember_digest, User.digest(remember_token)) 	#update vao remember_digest(su dung update tranh bao mat)
	end

#method authenticated? so sanh token va digest co trung nhau k
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

	#forgets 1 user
	def forget
		update_attribute(:remember_digest, nil)
	end

		def activate
		update_attribute(:activated, true)
		update_attribute(:activated_at, Time.zone.now)
	end

	def send_activation_email
		UserMailer.account_activation(self).deliver_now
	end

	private

	def downcase_email
		self.email = email.downcase
	end
#tao va gan activation token and digest
	def create_activation_digest
		self.activation_token = User.new_token
		self.activation_digest = User.digest(activation_token)
	end	
end
