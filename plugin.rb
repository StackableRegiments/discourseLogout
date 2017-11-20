# name: after-logout-endpoint
# about: An endpoint to redirect to after logout which performs additional functions to the user browser
# version: 0.0.2
# authors: Stackable Regiments pty ltd
# url: https://github.com/StackableRegiments/discourseLogout

enabled_site_setting :enhancedlogout_shouldClearCookies
enabled_site_setting :enhancedlogout_shouldClearBrowserSessionHistory
enabled_site_setting :enhancedlogout_shouldRedirect
enabled_site_setting :enhancedlogout_redirectUrl
enabled_site_setting :enhancedlogout_customLogoutPageHtml

register_asset "app/views/layouts/ender.html.erb"

after_initialize do

	module ::Enderpoint
		PLUGIN_NAME = "enhanced_logout".freeze
		
		class Engine < ::Rails::Engine
			engine_name PLUGIN_NAME
			isolate_namespace Enderpoint
		end
	end

	require_dependency "application_controller"

	class Enderpoint::EnderController < ::ApplicationController
		requires_plugin ::Enderpoint::PLUGIN_NAME

		skip_before_action :redirect_to_login_if_required
	
		##layout "plugins/#{current_app_code}/app/views/layouts/ender"

		def show 
			render plain: "<span>inserted content</span>"
		end
	end

	Enderpoint::Engine.routes.draw do
		get "/" => "ender#show"
	end	

	Discourse::Application.routes.append do
		mount ::Enderpoint::Engine, at: "/enhanced-logout"
	end	

end
