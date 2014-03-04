# Class: wso2esb
#
# This module manages wso2esb
#
# Parameters: none
#
# Actions:
#
# Requires: see Modulefile
#
# Sample Usage:
#
class wso2esb (
  $db_type= $wso2esb::params::db_type,
  $db_host        = $wso2esb::params::db_host,
  $db_name        = $wso2esb::params::db_name,
  $db_user        = $wso2esb::params::db_user,
  $db_password    = $wso2esb::params::db_password,
  $db_tag = $wso2esb::params::db_tag,
  $product_name   = $wso2esb::params::product_name,
  $download_site  = $wso2esb::params::download_site,
  $admin_password = $wso2esb::params::admin_password,
  $external_greg   = $wso2esb::params::external_greg,
  $greg_server_url   = $wso2esb::params::greg_server_url,
  $greg_db_host   = $wso2esb::params::greg_db_host,
  $greg_db_name        = $wso2esb::params::greg_db_name,
  $greg_db_type   = $wso2esb::params::greg_db_type,
  $greg_username   = $wso2esb::params::greg_username,
  $greg_password   = $wso2esb::params::greg_password,
  $version        = '4.6.0',) inherits wso2esb::params {
    if !($version in ['4.6.0']) {
    fail("\"${version}\" is not a supported version value")
  }
  $archive = "$product_name-$version.zip"
  $dir_bin = "/opt/${product_name}-${version}/bin/"
  exec { "get-esb-$version":
    cwd     => '/opt',
    command => "/usr/bin/wget ${download_site}${archive}",
    creates => "/opt/${archive}",
  }

  exec { "unpack-esb-$version":
    cwd       => '/opt',
    command   => "/usr/bin/unzip ${archive}",
    creates   => "/opt/${product_name}-$version",
    subscribe => Exec["get-esb-$version"],
    require   => Package['unzip'],
  }

case $db_type {
    undef: {
      # Use default H2 database
    }
    h2: {
      # Use default H2 database
    }
    mysql: {
  # we'll need a DB and a user for the local and config stuff
  @@mysql::db { $db_name:
    user     => $db_user,
    password => $db_password,
    host     => $::fqdn,
    grant    => ['all'],
    tag      => $db_tag,
  }

  file { "/opt/${product_name}-$version/repository/components/lib/mysql-connector-java-5.1.22-bin.jar":
    source  => "puppet:///modules/wso2esb/mysql-connector-java-5.1.22-bin.jar",
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-esb-$version"],
  }

  file { "/opt/${product_name}-$version/repository/conf/datasources/master-datasources.xml":
    content => template('wso2esb/master-datasources.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-esb-$version"],
  }

  if $external_greg == "true" {
  @@database_user { "${greg_username}@${fqdn}":
    ensure        => 'present',
    password_hash => mysql_password($greg_password),
    tag =>$db_tag,
  }
  @@database_grant { "${greg_username}@${fqdn}/${greg_db_name}":
      privileges => "all",
      tag =>$db_tag,
    }
      notice("asking grant")
    
    }
  
  
  }
    default: {
      fail('currently only mysql is supported - please raise a bug on github')
    }
  }



  file { "/opt/wso2esb-$version/repository/conf/registry.xml":
    content => template('wso2esb/registry.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-esb-$version"],
  }

  file { "/opt/wso2esb-$version/repository/conf/user-mgt.xml":
    content => template('wso2esb/user-mgt.xml.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    require => Exec["unpack-esb-$version"],
  }
  
  file { "/opt/${product_name}-$version/bin/wso2server.sh":
    owner   => 'root',
    group   => 'root',
    mode    => 0744,
    require => Exec["unpack-esb-$version"],
  }

  exec { 'setup-wso2esb':
    cwd       => "/opt/${product_name}-${version}/bin/",
    path => "/opt/wso2esb-${version}/bin/:/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin",
    environment => ["JAVA_HOME=/usr/java/default",],
    command   => "wso2server.sh -Dsetup",
    creates   => "/opt/${product_name}-$version/repository/logs/wso2carbon.log",
    unless => "/usr/bin/test -s /opt/${product_name}-$version/repository/logs/wso2carbon.log",
    logoutput => true,
    require   => [
      File["/opt/${product_name}-$version/repository/conf/user-mgt.xml"],
      File["/opt/${product_name}-$version/repository/conf/registry.xml"],
      File["/opt/${product_name}-$version/bin/wso2server.sh"],
      File["/opt/${product_name}-$version/repository/conf/datasources/master-datasources.xml"]],
  }
  
  file{'/etc/init.d/${product_name}':
    ensure => link,
    owner   => 'root',
    group   => 'root',
    target => "/opt/${product_name}-$version/bin/wso2server.sh",
    
  }

}
