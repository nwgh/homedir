function FindProxyForURL(url, host)
{
	if (isPlainHostName(host))
		return "DIRECT;";
	if (dnsDomainIs(host, ".arbor.net"))
		return "DIRECT;";
	if (dnsDomainIs(host, ".mow"))
		return "DIRECT;";
	if (dnsDomainIs(host, ".tb"))
		return "DIRECT;";
	if (dnsDomainIs(host, ".todesschaf.net"))
		return "DIRECT;";
	if (localHostOrDomainIs(host, "mail.todesschaf.org"))
		return "DIRECT;";
	if (localHostOrDomainIs(host, "hoover.arbor.net"))
		return "DIRECT;";
	if (localHostOrDomainIs(host, "imap.monkeymail.org"))
		return "DIRECT;";
	if (isInNet(host, "10.0.0.0", "255.0.0.0"))
		return "DIRECT;";
	if (isInNet(host, "192.168.0.0", "255.255.0.0"))
		return "DIRECT;";
	return "SOCKS 127.0.0.1:1080;";
}
