class nodejs {

  wget::fetch { 'https://rpm.nodesource.com/setup_6.x':
    destination => '/tmp/',
    verbose     => true,
  }

  exec { 'nodesource repo':
    command => '/bin/bash /tmp/setup_6.x',
    path    => [
      '/usr/local/bin',
      '/usr/bin',
      '/usr/local/sbin',
      '/usr/sbin',
      '/opt/puppetlabs/bin'
    ],
  }

  package { 'nodejs':
    ensure => latest,
  }

  Wget::Fetch['https://rpm.nodesource.com/setup_6.x']
  -> Exec['nodesource repo']
  -> Package['nodejs']

}
