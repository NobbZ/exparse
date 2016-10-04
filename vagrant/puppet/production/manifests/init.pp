include ::basics
include ::erlang
include ::elixir
include ::nodejs
include ::security

firewall { '22 - ssh!':
  dport => [2222, 22],
}
