class ApplicationController < ActionController::Base
#  include ExceptionNotifiable
  include AuthenticatedSystem
  include RoleRequirementSystem
  include HoptoadNotifier::Catcher

  helper :all # include all helpers, all the time
  protect_from_forgery :secret => 'b0a876313f3f9195e9bd01473bc5cd06'
  filter_parameter_logging :password, :password_confirmation
  before_filter :adjust_format_for_iphone
  
    
  def get_poly_obj(params)
    puts params.inspect
    puts "Obj Class: #{params[:obj_class]}"
    cls = eval(params[:obj_class])
    cls.find(params[:id])
  end
  
  private

    # Set iPhone format if request to iphone.trawlr.com
    def adjust_format_for_iphone
      request.format = :iphone if iphone_request?
    end

    # Force all iPhone users to login
    def iphone_login_required
      if iphone_request?
        redirect_to login_path unless logged_in?
      end
    end

    # Return true for requests to iphone.trawlr.com
    def iphone_request?
      #return true
      return (request.subdomains.first == "iphone" || params[:format] == "iphone")
    end
  
end
