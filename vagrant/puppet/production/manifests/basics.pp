class basics {
  $build_stuff = [
    # 'gcc', 'gcc-c++', 'glibc-devel', 'make', 'ncurses-devel', 'openssl-devel',
    # 'autoconf', 'wxBase.x86_64'
  ]

  $java_stuff = []# 'java-1.8.0-openjdk-devel' ]

  $vcs = [ 'git' ]

  $downloader = [ 'wget' ]

  $packages = $build_stuff + $java_stuff + $vcs + $downloader

  package { 'epel-release':
    ensure => latest,
  }

  package { $packages:
    ensure   => latest,
  }

  Package['epel-release'] -> Package[$packages]
}
