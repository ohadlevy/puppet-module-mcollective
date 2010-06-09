class mcollective::service {
  case $operatingsystem {
    ubuntu,debian,redhat,centos: { include mcollective::service::actual }
    default: { notice("${hostname}: mcollective: module does not yet support $operatingsystem") }
  }
}

class mcollective::service::actual {

  include mcollective::install
  include mcollective::config
  include mcollective::plugins

  service { "mcollective":
    ensure => running,
    hasstatus => true,
    hasrestart => true,
    require => Class["mcollective::install"],
  }
}

class mcollective::config {

  case $operatingsystem {
    debian,ubuntu: { $libdir = "/usr/share/mcollective/plugins" }
    redhat,centos: { $libdir = "/usr/libexec/mcollective" }
  }

  File { 
    owner => root,
    group => root,
    mode  => 0440,
    require => Class["mcollective::install"]
  }

  file { "/etc/mcollective":
    ensure => directory,
    owner => root, group => root, mode  => 0750,
    require => Class["mcollective::install"]
  }
  file { "/etc/mcollective/server.cfg": 
    content => template("mcollective/server.cfg.erb"),
    notify  => Service["mcollective"]
  }
  file { "/etc/mcollective/facts.yaml": 
    content => template("mcollective/facts.yaml.erb") 
  }

}

class mcollective::plugins {

  case $operatingsystem {
    debian,ubuntu: { $p_base = "/usr/share/mcollective/plugins/mcollective" }
    redhat,centos: { $p_base = "/usr/libexec/mcollective/mcollective" }
  }
  $s_base = "puppet:///mcollective/plugins"

  File { 
    owner => root, group => root, mode  => 0444,
    require => Class["mcollective::install"],
    notify => Service["mcollective"],
  }

  file { "${p_base}/facts/facter.rb": source => "${s_base}/facts/facter/facter.rb" }
  file { "${p_base}/agent/puppet-service.rb": source => "${s_base}/agent/service/puppet-service.rb" }
  file { "${p_base}/agent/puppet-package.rb": source => "${s_base}/agent/package/puppet-package.rb" }
  file { "${p_base}/agent/nrpe.rb": source => "${s_base}/agent/nrpe/nrpe.rb" }
  file { "${p_base}/agent/puppetd.rb": source => "${s_base}/agent/puppetd/puppetd.rb" }

}

class mcollective::install {
  case $operatingsystem {
    ubuntu,debian: { include mcollective::install::debian }
    redhat,centos: { include mcollective::install::redhat }
    default: { fail("${hostname}: mcollective: trying to install unsupported operatingsystem $operatingsystem") }
  }
}

class mcollective::install::redhat {

  package { "stomp": 
    name => "rubygem-stomp"
    ensure => "installed"
  }

  package { "mcollective": 
    ensure => present,
    require => Package["stomp"],
  }

}

class mcollective::install::debian {

  package { "stomp": 
    provider => gem, 
    ensure => "1.1",
  }

  package { "mcollective": 
    ensure => present,
    require => Package["stomp"],
  }
}
