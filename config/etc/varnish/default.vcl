backend default {
    .host = "127.0.0.1";
    .port = "3313";
}

acl purgeable {
  "localhost";
}

sub vcl_recv {
  unset req.http.Cookie;
        if (req.request == "PURGE") {
                if (!client.ip ~ purgeable) {
                        error 405 "Not allowed.";
                }
                return (lookup);
        }
}

sub vcl_hit {
        if (req.request == "PURGE") {
                purge;
                error 200 "Purged.";
        }
}

sub vcl_miss {
        if (req.request == "PURGE") {
                purge;
                error 200 "Purged.";
        }
}

sub vcl_fetch {

  unset beresp.http.Set-Cookie;
  set beresp.ttl = 365d;

  # Varnish determined the object was not cacheable
  if (!(beresp.ttl > 0s)) {
    set beresp.http.X-Cacheable = "NO:Not Cacheable, ttl <0s";
    set beresp.http.X-ttl = beresp.ttl;
    return(hit_for_pass);
  }
  elseif (req.http.Cookie) {
    set beresp.http.X-Cacheable = "NO:Got cookie";
    set beresp.http.X-Cookie = req.http.Cookie;
    return(hit_for_pass);
  }
  elseif (beresp.http.Cache-Control ~ "private") {
    set beresp.http.X-Cacheable = "NO:Cache-Control=private";
    return(hit_for_pass);
  }
  elseif (beresp.http.Cache-Control ~ "no-cache" || beresp.http.Pragma ~ "no-cache") {
    set beresp.http.X-Cacheable = "Refetch forced by user";
    return(hit_for_pass);
  # You are extending the lifetime of the object artificially
  }
  elseif (beresp.ttl < 1s) {
    set beresp.ttl   = 5s;
    set beresp.grace = 5s;
    set beresp.http.X-Cacheable = "YES:FORCED";
  # Varnish determined the object was cacheable
  } else {
    set beresp.http.X-Cacheable = "YES";
    set beresp.http.X-ttl = beresp.ttl;
  }
}
