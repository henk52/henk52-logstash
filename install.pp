# See: http://logstash.net/docs/1.4.2/tutorials/getting-started-with-logstash

# Also: http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-plugins.html

# Install:
# - logstach
exec { 'install_logstash':
  creates => '/opt/logstash-1.4.2',
  path    => [ '/bin', '/usr/bin' ],
  command => 'cd /opt; tar -zxvf /vagrant/files/logstash/logstash-1.4.2.tar.gz',
}

file { '/opt/logstash':
  ensure => link,
  require => Exec [ 'install_logstash' ],
  target  => '/opt/logstash-1.4.2',
}

# - elastisearch
exec { 'install_elastisearch':
  creates => '/opt/elasticsearch-1.1.1',
  path    => [ '/bin', '/usr/bin' ],
  command => 'cd /opt; tar -zxvf /vagrant/files/logstash/elasticsearch-1.1.1.tar.gz',
}

file { '/opt/elasticsearch':
  ensure => link,
  require => Exec [ 'install_logstash' ],
  target  => '/opt/elasticsearch-1.1.1',
}

file { '/usr/lib/systemd/system/elasticsearch.service':
  ensure => present,
  source => '/vagrant/files/logstash/elasticsearch.service',
}

service { 'elasticsearch':
  require => File [ '/opt/elasticsearch', '/usr/lib/systemd/system/elasticsearch.service' ],
  ensure  => running,
  enable  => true,
}

file { '/usr/lib/systemd/system/kibana.service':
  ensure => present,
  source => '/vagrant/files/logstash/kibana.service',
}

service { 'kibana':
  require => [
               File [ '/opt/logstash', '/usr/lib/systemd/system/kibana.service' ],
               Service [ 'elasticsearch' ],
             ],
  ensure  => running,
  enable  => true,
}

# - lmenezes/elasticsearch-kopf
# - redit?
# - kibana?

# TODO V redit
# TODO V systemd for each
package { 'perl-JSON-PP':
  ensure => present,
}

package { 'perl-Text-Template':
  ensure => present,
}

package { 'perl-XML-LibXML':
  ensure => present,
}


# Install the binaries for log operations.
$szTargetBinDir = "/home/vagrant/bin"
$szTargetEtcDir = "/home/vagrant/etc"
$szSourceLogstashDir = "/vagrant/logstash"

file { "$szTargetBinDir":
  ensure => directory,
  owner  => 'vagrant',
  group  => 'vagrant',
}

file { "$szTargetEtcDir":
  ensure => directory,
  owner  => 'vagrant',
  group  => 'vagrant',
}

file { "/home/vagrant/Readme_logstash.md":
  ensure  => present,
  source  => "$szSourceLogstashDir/README.md",
}
