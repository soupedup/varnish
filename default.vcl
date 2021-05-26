vcl 4.1;

import dynamic;
import directors;
backend default none;


sub vcl_init {
  new ddir = dynamic.director(
    port = "8080",
    ttl = 10s
  );
}

sub vcl_recv {
    set req.backend_hint = ddir.backend("ensayo.internal");
    if (req.method == "PURGE") {
        return(purge);
    }

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
