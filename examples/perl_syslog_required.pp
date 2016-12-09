# puppet apply perl_syslog_required.pp
package { 'perl-Sys-Syslog': ensure => present }
