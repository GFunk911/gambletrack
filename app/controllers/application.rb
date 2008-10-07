class ApplicationController < ActionController::Base
#  include ExceptionNotifiable
  include AuthenticatedSystem
  include RoleRequirementSystem

  helper :all # include all helpers, all the time
  protect_from_forgery :secret => 'b0a876313f3f9195e9bd01473bc5cd06'
  filter_parameter_logging :password, :password_confirmation
  
    
  def get_poly_obj(params)
    puts params.inspect
    puts "Obj Class: #{params[:obj_class]}"
    cls = eval(params[:obj_class])
    cls.find(params[:id])
  end
end
