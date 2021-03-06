vcl 4.1;

import std;
import dynamic;
import directors;
backend default none;


sub vcl_init {
  new ddir = dynamic.director(
    port = std.getenv("BACKEND_PORT"),
    ttl = 10s
  );
}

sub vcl_recv {
    set req.backend_hint = ddir.backend(std.getenv("BACKEND_HOST"));

    if (req.method == "BAN") {

	# TODO: implement ACL for allowed purge sources
        # if (!client.ip ~ purge) {
        #     return(synth(403, "Not allowed."));
        # }

        if (std.ban("obj.http.host == " + req.http.host)) {
            return(synth(200, "Ban added"));
        } else {
            # return ban error in 400 response
            return(synth(400, std.ban_error()));
        }
    }

}

sub vcl_backend_response {
    set beresp.http.host = bereq.http.host;
}

sub vcl_deliver {
    unset resp.http.host;
}


sub vcl_hit {
    set req.http.x-cache = "hit";
}

sub vcl_miss {
    set req.http.x-cache = "miss";
}

sub vcl_pass {
    set req.http.x-cache = "pass";
}

sub vcl_pipe {
    set req.http.x-cache = "pipe uncacheable";
}

sub vcl_synth {
    set req.http.x-cache = "synth synth";
    set resp.http.x-cache = req.http.x-cache;
}

sub vcl_deliver {
    if (obj.uncacheable) {
        set req.http.x-cache = req.http.x-cache + " uncacheable" ;
    } else {
        set req.http.x-cache = req.http.x-cache + " cached" ;
    }
    set resp.http.x-cache = req.http.x-cache;
}
