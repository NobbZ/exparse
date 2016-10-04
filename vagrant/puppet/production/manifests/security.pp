class security {

  resources { 'firewall':
    purge => true,
  }

  Firewall {
    before  => Class['security::firewall::post'],
    require => Class['security::firewall::pre'],
  }

}
