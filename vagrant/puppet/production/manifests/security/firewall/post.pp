class security::firewall::post {

  firewall { '99999 drop all':
    proto  => 'all',
    action => 'drop',
    before => undef,
  }

}
