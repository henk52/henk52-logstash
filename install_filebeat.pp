# Installing FileBeat on a client: 
#  https://www.elastic.co/downloads/beats/filebeat
#  

$szFileBeatVersion = "1.2.2"
$szFilebeatService = "/etc/init.d/filebeat"

exec { 'install_filebeat':
  creates => "/opt/filebeat-$szFileBeatVersion-x86_64",
  path    => [ '/bin', '/usr/bin' ],
  command => "tar -zxvf /vagrant/files/elk/filebeat-$szFileBeatVersion-x86_64.tar.gz",
  cwd     => '/opt',
}

file { '/opt/filebeat':
  ensure => link,
  require => Exec['install_filebeat'],
  target  => "/opt/filebeat-$szFileBeatVersion-x86_64",
}

service { 'filebeat':
  require => File['/opt/filebeat',"$szFilebeatService"],
  ensure  => running,
  enable  => true,
}

if  $osfamily == "Debian" {
file { '/etc/init.d/filebeat':
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

BEAT_HOME=/opt/filebeat
DAEMON=\$BEAT_HOME/bin/filebeat
NAME=elasticsearch
DESC=elasticsearch
PID_FILE=$szElkHomeDir/.\$NAME.pid
LOG_DIR=$szElasticSearchLogDir
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

} # end debian
