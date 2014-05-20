class powerline {
  include repository

  $powerline_repo = "${boxen::config::datadir}/powerline"

  repository{
    $powerline_repo:
      source   => 'Lokaltog/powerline',
      provider => 'git';
    "${powerline_repo}-fonts":
      source   => 'Lokaltog/powerline-fonts',
      provider => 'git';
  }

  # Has to be installed to the global python location
  exec { 'install powerline':
    cwd     => "${powerline_repo}/powerline",
    command  => ". ${boxen::config::home}/env.sh && \
      pip install -e .",
    provider => 'shell',
    user     => $::boxen_user,
    creates => "${homebrew::config::installdir}/lib/python2.7/site-packages/Powerline.egg-link";
  }

  #TODO: Require python to be installed...
  #TODO: Install the fonts for the system
  # See https://github.com/robbiegill/puppet-font/blob/master/manifests/init.pp
  #TODO: Setup a msg for the user to select a font to use in their terminal
  #TODO: Require janus, but what happens with vimrc.after?
  # convert to params? if so see file_line support from stdlib

  #TODO: Add tmux set -g support?
  # convert to params? if so see file_line support from stdlib

}
