# See: http://logstash.net/docs/1.4.2/tutorials/getting-started-with-logstash

# Also: http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-plugins.html

$szLogstashVersion = "2.3.2"
$szElasticSearchVersion = "2.3.2"

$szElkOwner = "elk"
$szElkHomeDir = "/home/$szElkOwner"


if  $osfamily == "Debian" {
  $szElasticsearch='/etc/init.d/elasticsearch'
  $szServiceControlFile = '/etc/init.d/elasticsearch'
  $szPkgPerlPurJson = "libjson-pp-perl"
} else {
  $szServiceControlFile = '/usr/lib/systemd/system/elasticsearch.service'
  $szPkgPerlPurJson = "perl-JSON-PP"
}


# The debian name.
$szPkgJava = 'openjdk-7-jre-headless'

if  $osfamily == "Debian" {
  $szPkgPerlTextTemplate = "libtext-template-perl"
} else {
  $szPkgPerlTextTemplate = "perl-Text-Template"
}

if  $osfamily == "Debian" {
  $szPkgPerlLibXml = 'libxml-libxml-simple-perl'
} else {
  $szPkgPerlLibXml = 'perl-XML-LibXML'
}

# Install:
# - logstash
exec { 'install_logstash':
  creates => "/opt/logstash-$szLogstashVersion",
  path    => [ '/bin', '/usr/bin' ],
  command => "tar -zxvf /vagrant/files/elk/logstash-$szLogstashVersion.tar.gz",
  cwd     => '/opt',
}

file { '/opt/logstash':
  ensure => link,
  require => Exec['install_logstash'],
  target  => "/opt/logstash-$szLogstashVersion",
}

package { "$szPkgJava": ensure => present }

# - elastisearch
exec { 'install_elastisearch':
  creates => "/opt/elasticsearch-$szElasticSearchVersion",
  path    => [ '/bin', '/usr/bin' ],
  cwd     => '/opt',
  command => "tar -zxvf /vagrant/files/elk/elasticsearch-$szElasticSearchVersion.tar.gz",
}

file { '/opt/elasticsearch':
  ensure => link,
  require => Exec['install_logstash'],
  target  => "/opt/elasticsearch-$szElasticSearchVersion",
}

file { '/opt/elasticsearch/plugins':
  ensure => directory,
  owner  => "$szElkOwner",
  group  => "$szElkOwner",
  require => [User["$szElkOwner"],File['/opt/elasticsearch']],
}

file { '/opt/elasticsearch/config/scripts':
  ensure => directory,
  owner  => "$szElkOwner",
  group  => "$szElkOwner",
  require => [User["$szElkOwner"],File['/opt/elasticsearch']],
}

file { '/var/lib/elasticsearch':
  ensure => directory,
  owner  => "$szElkOwner",
  group  => "$szElkOwner",
  require => User["$szElkOwner"],
}

#              File['/opt/elasticsearch',"$szServiceControlFile",'/opt/elasticsearch/plugins','/opt/elasticsearch/config/scripts','/var/lib/elasticsearch'],
notify { 't':
  message => "szServiceControlFile $szServiceControlFile",
}


service { 'elasticsearch':
  require => [
              File['/opt/elasticsearch','/opt/elasticsearch/plugins','/opt/elasticsearch/config/scripts','/var/lib/elasticsearch'],
              Package["$szPkgJava"],
             ],
  ensure  => running,
  enable  => true,
}

# Logstash depends on elasticsearch.
#  require => [
#               File [ '/opt/logstash', '/usr/lib/systemd/system/kibana.service' ],
#               Service [ 'elasticsearch' ],
#             ],
#  ensure  => running,
#  enable  => true,
#}

# - lmenezes/elasticsearch-kopf
# - redit?
# - kibana?

# TODO V redit
# TODO V systemd for each
package { "$szPkgPerlPurJson":
  ensure => present,
}

package { "$szPkgPerlTextTemplate":
  ensure => present,
}

package { "$szPkgPerlLibXml":
  ensure => present,
}


# Install the binaries for log operations.
$szTargetBinDir = "/home/$szElkOwner/bin"
$szTargetEtcDir = "/home/$szElkOwner/etc"
$szElasticSearchLogDir = "/var/log/elasticsearch"
$szSourceLogstashDir = "/vagrant/logstash"

user { "$szElkOwner":
  ensure     => present,
  home       => "$szElkHomeDir",
  managehome => true,
}

file { "$szTargetBinDir":
  ensure => directory,
  owner  => "$szElkOwner",
  group  => "$szElkOwner",
  require => User["$szElkOwner"],
}

file { "$szTargetEtcDir":
  ensure => directory,
  owner  => "$szElkOwner",
  group  => "$szElkOwner",
  require => User["$szElkOwner"],
}

file { "$szElasticSearchLogDir":
  ensure => directory,
  owner  => "$szElkOwner",
  group  => "$szElkOwner",
  require => User["$szElkOwner"],
}

file { "/home/$szElkOwner/Readme_logstash.md":
  ensure  => present,
  source  => "$szSourceLogstashDir/README.md",
  require => User["$szElkOwner"],
}

if  $osfamily == "Debian" {
file { '/etc/init.d/elasticsearch':
  ensure  => present,
  mode    => 555,
  content => "#! /bin/sh
# From: https://gist.github.com/andywenk/3569769
### BEGIN INIT INFO
# Provides:          elasticsearch
# Required-Start:    $all
# Required-Stop:     $all
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Starts elasticsearch
# Description:       Starts elasticsearch using start-stop-daemon
### END INIT INFO

ES_HOME=/opt/elasticsearch
ES_MIN_MEM=256m
ES_MAX_MEM=2g
DAEMON=\$ES_HOME/bin/elasticsearch
NAME=elasticsearch
DESC=elasticsearch
PID_FILE=$szElkHomeDir/.\$NAME.pid
#PID_FILE=/var/run/\$NAME.pid
LOG_DIR=$szElasticSearchLogDir
#LOG_DIR=/var/log/\$NAME
DATA_DIR=/var/lib/\$NAME
WORK_DIR=/tmp/\$NAME
DMN_USER=$szElkOwner
#CONFIG_FILE=/etc/\$NAME/elasticsearch.yml
DAEMON_OPTS=\"-d -p \$PID_FILE -Des.path.home=\$ES_HOME -Des.path.logs=\$LOG_DIR -Des.path.data=\$DATA_DIR -Des.path.work=\$WORK_DIR\"


if [ ! -x \"\$DAEMON\" ]
then
  echo \"File '\$DAEMON' is not executable or found\"
  exit 2
fi

set -e

case \"\$1\" in
  start)
    echo -n \"Starting \$DESC: \"
    mkdir -p \$LOG_DIR \$DATA_DIR \$WORK_DIR
    if start-stop-daemon --start --chuid \$DMN_USER --pidfile \$PID_FILE --startas \$DAEMON -- \$DAEMON_OPTS
    then
        echo 'started.'
    else
        echo 'failed.'
    fi
    ;;
  stop)
    echo -n \"Stopping \$DESC: \"
    if start-stop-daemon --stop --pidfile \$PID_FILE
    then
        echo 'stopped.'
    else
        echo 'failed.'
    fi
    ;;
  restart|force-reload)
    \${0} stop
    sleep 0.5
    \${0} start
    ;;
  *)
    N=/etc/init.d/\$NAME
    echo \"Usage: \$N {start|stop|restart|force-reload}\" >&2
    exit 1
    ;;
esac

exit 0",
}
} # endif debian.


# TODO make a var about the Init process, wither it is startup or systemd.
if  $osfamily == "Redhat" {
file { '/usr/lib/systemd/system/elasticsearch.service':
  ensure => present,
  source => '/vagrant/files/logstash/elasticsearch.service',
}
file { '/usr/lib/systemd/system/kibana.service':
  ensure => present,
  source => '/vagrant/files/logstash/kibana.service',
}

#service { 'kibana':
} # end redhat


