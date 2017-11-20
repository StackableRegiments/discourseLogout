# name: after-logout-endpoint
# about: An endpoint to redirect to after logout which performs additional functions to the user browser
# version: 0.0.1
# authors: Stackable Regiments pty ltd

enabled_site_setting :enhancedlogout_shouldClearCookies
enabled_site_setting :enhancedlogout_shouldClearBrowserSessionHistory
enabled_site_setting :enhancedlogout_shouldRedirect
enabled_site_setting :enhancedlogout_redirectUrl

register_asset 'javascripts/discourse/templates/plugins-enhanced-logout.hbs'

after_initialize do
	Discourse::Application.routes.append do
		get '/enhanced-logout' => 'enhanced_logout#index'
	end
end	
