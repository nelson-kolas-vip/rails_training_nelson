class CounterController < ApplicationController
  def show
    session[:count] ||= 0
    @count = session[:count]
  end

  def increment
    session[:count] ||= 0
    session[:count] += 1         # Increment the session value
    redirect_to count_path       # Redirect back to the /count page
  end

  def reset
    session[:count] = 0
    redirect_to count_path
  end

end
