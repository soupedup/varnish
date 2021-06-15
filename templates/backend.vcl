# To be placed in the vcl_recv() block

set req.backend_hint = ddir.backend("app.internal")

if ( req.host == "discuss.app.com") {
    set req.backend_hint = ddir.backend("forum.internal");
}

if ( req.url ~ "^/cable" ) {
    set req.backend_hint = ddir.backend("anycable.internal");
}