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

after_initialize do

	module ::EnhancedLogoutEndpoint
		PLUGIN_NAME = "enhanced_logout_plugin".freeze
		
		class Engine < ::Rails::Engine
			engine_name PLUGIN_NAME
			isolate_namespace EnhancedLogoutEndpoint
		end
	end

	require_dependency "application_controller"

	class EnhancedLogoutEndpoint::EnhancedLogoutController < ::ApplicationController
		requires_plugin ::EnhancedLogoutEndpoint::PLUGIN_NAME

		layout :false
		skip_before_action :redirect_to_login_if_required
		
		def generateRedirectScript
			redirectUrl = SiteSettings.enhancedlogout_redirectUrl
			<<-EMBEDDEDSCRIPT
	<script type="text/javascript">
	var redirectUrl = "#{redirectUrl}";
	console.log("redirectingTo:",redirectUrl);
	</script>
			EMBEDDEDSCRIPT
		end	

		def generateCookieRemovalScript
			<<-EMBEDDEDSCRIPT
	<script type="text/javascript">
	console.log("removing cookies");
	</script>
			EMBEDDEDSCRIPT
		end	

		def generateBrowserBackScript
			<<-EMBEDDEDSCRIPT
	<script type="text/javascript">
	console.log("clearing browser session history");
	</script>
			EMBEDDEDSCRIPT
		end	

		def customPageContent
			SiteSettings.enhancedlogout_customLogoutPageHtml
		end	

		def performPostLogout
			renderedPage = '<html><head>'
			if SiteSettings.enhancedlogout_shouldClearCookies? 
				renderedPage = renderedPage + generateCookieRemovalScript
			end	
			if SiteSettings.enhancedlogout_shouldClearBrowserSessionHistory? 
				renderedPage = renderedPage + generateBrowserBackScript
			end	
			if SiteSettings.enhancedlogout_shouldRedirect? 
				renderedPage = renderedPage + generateCookieRemovalScript
			end	
			renderedPage = renderedPage + '</head><body>#{customPageContent}</body></html>'
			render :inline => renderedPage.html_safe
		end	
	end

	EnhancedLogoutEndpoint::Engine.routes.draw do
		get "/" => "enhancedLogout#performPostLogout"
	end	

	Discourse::Application.routes.append do
		mount ::EnhancedLogoutEndpoint::Engine, at: "/enhanced-logout"
	end	

end
