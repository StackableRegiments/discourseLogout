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
var getDocumentCookie = function(){
	return document.cookie.split(";");
};
var getDomainParts = function(){
	return window.location.hostname.split(".");
};
var getPathParts = function(){
	return window.location.pathname.split("/");
};
var cookies = getDocumentCookie();
console.log("clearingCookies",cookies);
var oneDay = 24 * 60 * 60 * 1000;
var expiringDate = new Date(new Date().getTime() - oneDay).toGMTString();
var domainParts = getDomainParts();
var pathParts = getPathParts();
for (var i = 0; i < cookies.length; i++){
	var cookie = cookies[i];
	var parts = cookie.split("=");
	var name = parts[0];
	var value = parts[1];
	if (name !== ""){
		var terminalCookie = name+"="+value+"; expires="+expiringDate+"; path=/;";
		console.log("clearing base cookie: ",cookie,terminalCookie);
		document.cookie = terminalCookie;
		for (var di = domainParts.length - 1; di >= 0; di--){
			for (var pi = 0; pi <= pathParts.length; pi++){
				var domain = domainParts.slice(di,domainParts.length).join(".");
				var path = "/"+pathParts.slice(0,pi).join("/");
				var terminalCookie = name+"="+value+"; expires="+expiringDate+"; path="+path+"; domain="+domain+";"
				console.log("clearing potential cookie: ",cookie,terminalCookie);
				document.cookie = terminalCookie;
			}
		}
	}
}
cookies = getDocumentCookie();
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
