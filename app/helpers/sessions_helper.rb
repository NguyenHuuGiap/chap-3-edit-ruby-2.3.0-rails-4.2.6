module SessionsHelper

#Tao phien lam viec cho nguoi dung theo user id
	def log_in(user)
		session[:user_id] = user.id
	end
#Ghi nho nguoi dung trong 1 session
	def remember(user)
		user.remember
    	cookies.permanent.signed[:user_id] = user.id
    	cookies.permanent[:remember_token] = user.remember_token

	end

	def current_user?(user)
		user == current_user
	end
#Return ra nguoi log in hien tai
	def current_user
		if (user_id = session[:user_id])
      		@current_user ||= User.find_by(id: user_id)
   		elsif (user_id = cookies.signed[:user_id])
      		user = User.find_by(id: user_id)
     		if user && user.authenticated?(:remember, cookies[:remember_token])
        	log_in user
        	@current_user = user
      		end
    	end

	end
#Return true neu nguoi dung dang log in va false neu nguoi lai
	def logged_in?
		!current_user.nil?
	end

#Quen 1 phien lam viec
	def forget(user)
		user.forget
		cookies.delete(:user_id)
		cookies.delete(:remember_token)
	end
#logs out nguoi dung hien tai
	def log_out
		forget(current_user)
		session.delete(:user_id) #huy session theo id
		@current_user = nil		#gan cho bien current_user = nil
	end
#Chuyển hướng đến vị trí lưu trữ (hoặc để mặc định).
	def redirect_back_or(default)
		redirect_to(session[:forwarding_url] || default)
		session.delete(:forwarding_url)
	end

#truy cap vao srore
	def store_location
		session[:forwarding_url] = request.url if request.get?
		
	end
end
