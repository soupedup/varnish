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
    set req.backend_hint = ddir.backend("app.internal")

    if ( req.host == "discuss.app.com") {
        set req.backend_hint = ddir.backend("forum.internal");
    }

    if ( req.url ~ "^/cable" ) {
        set req.backend_hint = ddir.backend("anycable.internal");
    }
}