export default {
  resource: 'user',
	path: '/enhanced-logout',
	map() {
		this.route('enhanced-logout-route', {path: '/'});
	}
}
