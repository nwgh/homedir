/* -*- mode: javascript-generic -*- */

/* These two are transformed from network/base/src/nsProxyAutoConfig.js from
   the mozilla source code, to work better with my purposes */
function ip_aton(ip) {
    var bytes = ip.split('.');
    var result = ((bytes[0] & 0xff) << 24) |
                 ((bytes[1] & 0xff) << 16) |
                 ((bytes[2] & 0xff) <<  8) |
                  (bytes[3] & 0xff);
    return result;
}

function ip_in_net(ip, net, mask) {
    var test = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/(ip);

    if (test == null) {
        return false; // Not a dotted quad
    } else if (test[1] > 255 || test[2] > 255 ||
               test[3] > 255 || test[4] > 255) {
        return false; // Not an IP address
    }

    ip = ip_aton(ip);
    net  = ip_aton(net);
    mask = ip_aton(mask);

    return ((ip & mask) == (net & mask));

}

/* Object to keep networks for checking network location of destination */
function Network(net, mask) {
    this.net = net;
    this.mask = mask;
}

/* Let me get to the hg web interface from home, everything else is direct */
function proxy_home(url, host) {
	if (localHostOrDomainIs(host, "hg.todesschaf.org"))
		return "SOCKS 127.0.0.1:1080;";
	return "DIRECT;";
}

/* Proxy most of my traffic within Arbor, but make direct connections to
   work machines and mail servers */
function proxy_work(url, host) {
    var direct_domains = [".arbor.net", ".aa", ".lex", ".mow", ".tb"];

    var direct_hosts = ["mail.todesschaf.org", "cross.arbor.net",
                        "imap.monkeymail.org"];

    var direct_nets = [new Network("10.0.0.0", "255.0.0.0"),
                       new Network("172.16.0.0", "255.240.0.0"),
                       new Network("192.168.0.0", "255.255.0.0")];

    if (isPlainHostName(host)) {
        return "DIRECT;";
    }

    for (var i = 0; i < direct_domains.length; i++) {
        if (dnsDomainIs(host, direct_domains[i])) {
            return "DIRECT;";
        }
    }

    for (var i = 0; i < direct_hosts.length; i++) {
        if (localHostOrDomainIs(host, direct_hosts[i])) {
            return "DIRECT;";
        }
    }

    for (var i = 0; i < direct_nets.length; i++) {
        if (ip_in_net(host, direct_nets[i].net, direct_nets[i].mask)) {
            return "DIRECT;";
        }
    }

    return "SOCKS 127.0.0.1:1080;";
}

/* The "public" function that is called by the browser to determine how to
   proxy the traffic */
function FindProxyForURL(url, host) {
    var myip = myIpAddress();
    if (ip_in_net(myip, "192.168.0.0", "255.255.255.0")) {
        return proxy_home(url, host);
    } else if (ip_in_net(myip, "10.1.6.0", "255.255.254.0")) {
        // TODO - get the VPN net for here
        return proxy_work(url, host);
    } else {
        // Not at home, not at work == ALWAYS proxy
        return "SOCKS 127.0.0.1:1080;";
    }
}
