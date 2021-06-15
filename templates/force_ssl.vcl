sub vcl_recv {
    if (req.http.X-Forwarded-Proto !~ "(?i)https") {
        return (synth(750, ""));
    }
}

sub vcl_synth {
    if (resp.status == 750) {
        set resp.status = 301;
        set resp.http.Location = req.url;
        return(deliver);
    }
}
