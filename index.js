var http = require('http'),
	fs = require('fs'),
	url = require('url'),
	memento = require('memento-client'),
	request = require('hyperquest');

var WAYBACK_HOST = 'web.archive.org',
	isAsset = /\/web\/\d{14}/;

function notFound(res) {

	res.writeHead(404, {'content-type': 'text/html'});
	res.end('<html><body><h1>Page Not Found</h1></body></html>');

}

http.createServer(function(req, res) {

	var assetUrl;

	if (!isAsset.test(req.url)) {

		memento('http://www.flickr.com' + req.url, '2004-07-01', function(err, mementos) {

			if (err || mementos.length < 2) {

				return notFound(res);

			} else {

				if (mementos[1].datetime.indexOf(' 2004 ') === -1) {
					return notFound(res);
				}

				request.get(mementos[1].href, function(err, response) {

					response.pipe(res);
					res.writeHead(response.statusCode, response.headers);

				});

			}

		});

	} else {

		assetUrl = url.format({
			host: WAYBACK_HOST,
			pathname: url.parse(req.url).path,
			protocol: 'http'
		});

		request.get(assetUrl, assetRespond);

		function assetRespond(err, response) {

			if (err) {
				return notFound(res);
		  	}

		  	if (response.statusCode === 302) {
				
				assetUrl = url.format({
					host: WAYBACK_HOST,
					pathname: response.headers.location,
					protocol: 'http'
				});

				return request.get(assetUrl, assetRespond);

			}

			res.writeHead(response.statusCode, response.headers);

		  	if (response.statusCode < 200 || response.statusCode > 299) {
				return res.end();
		  	}

		  	response.pipe(res);

		}

	}

}).listen(3313, '127.0.0.1');