# flickr2004

Flickr circa 2004 by proxying the Wayback Machine.

The code is 99% [peabody](https://github.com/jarofghosts/peabody), I just made a few modifications to specifically proxy flickr.ws to the Wayback Machine's archive of http://www.flickr.com around July 1, 2004.

Then I put a varnish cache in front of it and set the TTL to 1 year.