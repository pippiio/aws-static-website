function handler(event) {
	var request = event.request;

	var prefix = request.headers.host.value.split('.')[0];
	request.uri = '/' + prefix + request.uri;

	return request;
}