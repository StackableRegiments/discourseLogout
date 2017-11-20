# name: after-logout-endpoint
# about: An endpoint to redirect to after logout which performs additional functions to the user browser
# version: 0.0.2
# authors: Stackable Regiments pty ltd
# url: https://github.com/StackableRegiments/discourseLogout

enabled_site_setting :enhancedLogout_enabled

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
		skip_before_action :redirect_to_login_if_required, :check_xhr

		def clearBrowserHistory
			if SiteSetting.enhancedLogout_should_clear_cookies? then
				<<~SCRIPT_CONTENT
console.log("clearing browser history");
SCRIPT_CONTENT
			else 
				""
			end
		end	
		
		def clearCookies
			if SiteSetting.enhancedLogout_should_clear_browser_session_history? then
				<<~SCRIPT_CONTENT
var cookies = document.cookie.split(";");
console.log("clearingCookies",cookies);
var oneDay = 24 * 60 * 60 * 1000;
var expiringDate = new Date(new Date().getTime() - oneDay);
for (var i = 0; i < cookies.length; i++){
	var cookie = cookies[i];
	var parts = cookie.split("=");
	var name = parts[0];
	var value = parts[1];
	document.cookie = name+"="+value+"; expires="+expiringDate.toGMTString()+"; path=/";
}
cookies = document.cookie.split(";");
console.log("clearedCookies",cookies);
SCRIPT_CONTENT
			else 
				""
			end
		end

		def redirectAgain
			if SiteSetting.enhancedLogout_should_redirect? && !SiteSetting.enhancedLogout_redirect_url.blank? then
				<<~SCRIPT_CONTENT
var redirectionLocation = "#{SiteSetting.enhancedLogout_redirect_url}";
console.log("redirecting to",redirectionLocation);
window.location = redirectionLocation;
SCRIPT_CONTENT
			else
				""
			end
		end
		
		def closeTab
			if SiteSetting.enhancedLogout_should_close_tab? then
				<<~SCRIPT_CONTENT
console.log("attempting to close tab");
window.open('','_self').close();				
SCRIPT_CONTENT
			else 
				""
			end

		end

		def showContent
			SiteSetting.enhancedLogout_custom_logout_page_html
		end

		def index 
			render inline: <<-HTML_CONTENT
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
	<head>
		<script type="text/javascript">
			#{clearBrowserHistory}
			#{clearCookies}
			#{redirectAgain}
			#{closeTab}
		</script>	
	</head>
	<body>
		#{showContent}
	</body>
</html>
HTML_CONTENT
		end
	end

	Enderpoint::Engine.routes.draw do
		get "/" => "ender#index"
	end	

	Discourse::Application.routes.append do
		mount ::Enderpoint::Engine, at: "/enhanced-logout"
	end	

end
