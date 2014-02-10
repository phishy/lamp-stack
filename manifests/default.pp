# this makes puppet and vagrant shut up about the puppet group
group { "puppet": 
  ensure => "present", 
}

# make sure the packages are up to date before beginning
exec { "apt-get update":
  command => "/usr/bin/apt-get update",
}

# because puppet command are not run sequentially, ensure that packages are
# up to date before installing before installing packages, services, files, etc.
Package { require => Exec["apt-get update"] }
File { require => Exec["apt-get update"] }

# ensure packages are installed to create a LAMP environment
package { "vim":
  ensure => present,
}
package { "apache2":
  ensure => present,
}
package { "php5":
  ensure => present,
}
package { "mysql-server":
  ensure => present,
}
package { "php5-mysql":
  ensure => present,
}
package { "php-pear":
  ensure => present,
}
package { "php5-xdebug":
  ensure => present,
}

# upgrades PEAR, installs Codesniffer and PHPUnit
exec {"/usr/bin/pear upgrade": 
  require => Package['php-pear']
}
exec { "/usr/bin/pear install PHP_Codesniffer":
  require => [Package['php-pear'], Exec['/usr/bin/pear upgrade']]
}
exec { "/usr/bin/pear config-set auto_discover 1":
  require => [Package['php-pear'], Exec['/usr/bin/pear upgrade']]
}
exec { "/usr/bin/pear install pear.phpunit.de/PHPUnit":
  require => [Package['php-pear'], Exec['/usr/bin/pear config-set auto_discover 1'], Exec['/usr/bin/pear upgrade']]
}

# starts the apache2 service once the packages installed, and monitors changes
# to its configuration files and reloads if necessary
service { "apache2":
  ensure => running,
  enable => true,
  require => Package['apache2'],
  subscribe => [File["/etc/apache2/mods-enabled/rewrite.load"], File["/etc/apache2/sites-available/default"]],
}

# ensures that mod_rewrite is loaded and modifies the default configuration file
file { "/etc/apache2/mods-enabled/rewrite.load":
  ensure => link,
  target => "/etc/apache2/mods-available/rewrite.load",
  require => Package['apache2'],
}
file { "/etc/apache2/sites-available/default":
  ensure => present,
  source => "/vagrant/manifests/default",
}  

