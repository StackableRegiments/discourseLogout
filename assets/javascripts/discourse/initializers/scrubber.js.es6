import { withPluginApi } from 'discourse/lib/plugin-api';

import { cleanDOM} from 'discourse/lib/clean-dom';
import { startPageTracking, onPageChange } from 'discourse/lib/page-tracker';
import { viewTrackingRequired } from 'discourse/lib/ajax';

function scrubHistory(url,title){
	if ("history" in window){
		console.log("scrubbing history using the HTML5 history API");
		window.history.replaceState({},"","/");
	}
};

export default {
	name: 'historyScrubber',
	initialize(container) {
		withPluginApi('0.1',api => {
			var siteSettings = api.container.lookup('site-settings:main');
			console.log('scrub-time:',siteSettings);
			if ("enhancedLogout_scrub_browser_history" in siteSettings && siteSettings.enhancedLogout_scrub_browser_history == true){
				var router = container.lookup('router:main');
				router.on('willTransition',viewTrackingRequired);
				router.on('didTransition',cleanDOM);

				startPageTracking(router);

				api.onPageChange((url,title) => {
					console.log("page changed:",url,title);
					if ("enhancedLogout_scrub_browser_history" in siteSettings && siteSettings.enhancedLogout_scrub_browser_history == true){
						scrubHistory(url,title);	
					}
				});
			}
		});
	}
};
