class elixir {

  firewall { '4000 - Phoenix dev-server':
    dport => 4000,
  }

  vcsrepo { '/tmp/elixir':
    ensure   => latest,
    provider => git,
    source   => 'https://github.com/elixir-lang/elixir.git',
    revision => 'v1.3',
  }

  exec { 'compile elixir':
    command     => '/usr/bin/make install',
    creates     => '/usr/local/bin/elixir',
    cwd         => '/tmp/elixir',
    path        => '/usr/bin',
    environment => 'HOME=/root',
    # refreshonly => true,
  }

  exec { 'install hex':
    command     => '/usr/local/bin/mix local.hex --force',
    user        => 'vagrant',
    creates     => '/home/vagrant/.mix/archives/hex-0.13.0/',
    path        => ['/usr/bin', '/usr/local/bin'],
    environment => 'HOME=/home/vagrant',
  }

  exec { 'install rebar':
    command     => '/usr/local/bin/mix local.rebar --force',
    user        => 'vagrant',
    creates     => '/home/vagrant/.mix/rebar',
    path        => ['/usr/bin', '/usr/local/bin'],
    environment => 'HOME=/home/vagrant',
  }

  exec { 'install phoenix generator':
    command     => '/usr/local/bin/mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez',
    user        => 'vagrant',
    creates     => '/home/vagrant/.mix/archives/phoenix_new/',
    path        => ['/usr/bin', '/usr/local/bin'],
    environment => 'HOME=/home/vagrant',
  }

  [ Vcsrepo['/tmp/elixir'], Package['erlang'] ]
  ~> Exec['compile elixir']
  ~> [ Exec['install hex'], Exec['install rebar'] ]
  ~> Exec['install phoenix generator']
}
