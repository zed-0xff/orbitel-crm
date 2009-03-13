class LoginSteps < Spec::Story::StepGroup
  steps do |define|
    define.given("a user registered with login: $login and password: $password") do |login,password|
      @user = User.create!(
        :login                 => login,
        :password              => password,
        :password_confirmation => password
      )
    end

    define.when("user logs in with login: $login and password: $password") do |login,password|
      post '/sessions/create', :login => login, :password => password
    end

    define.then("user should see the welcome page") do
      response.should be_redirect
      response.should redirect_to('/')
    end

    define.then("user should see the login form") do
      response.should be_success
      response.should render_template('sessions/new')
    end

    define.then("page should include text: $text") do |text|
      response.body.should include(text)
    end
  end
end


