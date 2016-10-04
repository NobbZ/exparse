class security::firewall::pre {

  include ::firewall

  Firewall {
    require => undef,
  }

  firewall    { '00000 - accept all ICMP': proto => icmp, action => accept }
  -> firewall { '00001 - accept all lo':   proto => all,  action => accept, iniface => lo }
  -> firewall { '00002 - reject not lo':   proto => all,  action => reject, iniface => '! lo', destination => '127.0.0.1/8' }
  -> firewall { '00003 - accept related':  proto => all,  action => accept, state => ['RELATED', 'ESTABLISHED'] }

}
