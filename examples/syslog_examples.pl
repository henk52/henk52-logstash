#!/usr/bin/perl -w
use strict;

# http://www.ietf.org/rfc/rfc3164.txt

#use Sys::Syslog qw(:standard :macros);
use Sys::Syslog qw(:standard :extended :macros);

# ndelay - Open the connection immediately (normally, the connection is opened when the first message is logged).
# pid - Include PID with each message.

  setlogsock("udp");
  openlog("systelogtest", "ndelay,pid", LOG_LOCAL0);

  syslog(LOG_INFO, "Message"); 
  closelog();
