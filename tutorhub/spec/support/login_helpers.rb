module LoginHelpers
  # Sets the session user_id for the next request via the Rails session cookie
  # store. Works for both request specs and controller specs.
  def login_as(user)
    if respond_to?(:cookies) && cookies.respond_to?(:[]=)
      # Request spec: write to the cookie jar so that the next request picks
      # up the session containing user_id.
      post '/login', params: { email: user.email, password: 'password123' }
    elsif respond_to?(:session) && session.respond_to?(:[]=)
      session[:user_id] = user.id
    end
  end

  def sign_out
    return unless respond_to?(:session) && session.respond_to?(:[]=)

    session[:user_id] = nil
  end
end
