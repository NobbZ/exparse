# == Class: erlang
#
class erlang {

  wget::fetch { 'http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm':
    destination => '/tmp/',
    verbose     => true,
  }

  package { 'erlang':
    ensure => latest,
  }

  package { 'erlang-solutions':
    ensure   => latest,
    provider => rpm,
    source   => '/tmp/erlang-solutions-1.0-1.noarch.rpm',
  }


  Wget::Fetch['http://packages.erlang-solutions.com/erlang-solutions-1.0-1.noarch.rpm']
  -> Package['erlang-solutions']
  -> Package['erlang']
}
