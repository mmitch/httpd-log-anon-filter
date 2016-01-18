httpd-log-anon-filter
=====================

about
-----

httpd-log-anon-filter is an anonymizing log filter for httpd logs.

It is used to change the IP address/hostname field of webserver logs
to something else than the original IP address/hostname in order to
comply with German data privacy laws.

The project homepage is at https://github.com/mmitch/httpd-log-anon-filter


copyright
---------

httpd-log-anon-filter - anonymizing log filter for httpd logs  
Copyright (C) 2016  Christian Garbs <mitch@cgarbs.de>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.


dependencies
------------

- Perl


usage
-----

    usage:
        httpd-log-anon-filter.pl <output_logfile>

httpd-log-anon-filter reads data in common or combined log format (in
fact any data that has the IP address or hostname in the first
whitespace delimited field on a line) from STDIN and appends the
processed output to a filename given as the first and only commandline
argument.  Giving no output filename results in an error.

For every log line received, the IP address/hostname is hashed using
MD5 and a new IP address (IPv6 for IPv6 input data, IPv4 for
everything else) is generated.  The new address replaces the old
address/hostname and the new log line is written to the given
filename.

On every startup, httpd-log-anon-filter generates a salt, so multiple
invocations won't generate the same output for the same input.  As
long as httpd-log-anon-filter is not restarted, any given input
address is always mapped to the same output address, so it is still
possible to read logs in realtime and look for errors or follow some
patterns.

On common system configurations (eg. Debian's default Apache
installation), logs are rotated daily and thus the webserver is
reloaded, which will also restart httpd-log-anon-filter and give you
a new salt every day.

Beware that multiple instances of httpd-log-anon-filter will work with
different salts, eg. when you have a non-SSL configuration and an SSL
configuration both logging to the same file, they will possibly spawn
two instances of httpd-log-anon-filter and the same source address
will be mapped differently in the logs, depending on whether a http
or https request was issued.


### usage with Apache ###

Apache 2.4 supports
[piped logs](https://httpd.apache.org/docs/2.4/logs.html#piped).
To use httpd-log-anon-filter, add a ``CustomLog`` statement like this:

    CustomLog "| /path/to/httpd-log-anon-filter.pl /var/log/access_log" combined

This will write an anonymized log to the default log location
``/var/log/access_log``.  Apache automatically starts and stops
httpd-log-anon-filter as needed, log rotation and maintenance should
simply work as before.


customization
-------------

Currently, httpd-log-anon-filter can't really be customized.  You can
comment/uncomment some parts of the code:

 * IPv6 addresses are be default completely randomized.  Most hashes
   will propably be non-existing addresses, but others will be real
   and your log will simply contain wrong information (well, that's
   the point in the first place).  If for any reason you want to 'play
   nice', you can uncomment one of two other lines instead to either
   only generate addresses from ``2001:db8::/32`` (address range
   reserved for documentation purposes) or from ``0100::/64`` (discard).

 * IPv4 addresses are also completely randomized.  Here the
   alternative is to use addresses from ``10.0.0.0/8`` (private
   address range), but that leaves you only with 24 random bits.
