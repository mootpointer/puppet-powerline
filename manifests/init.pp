class powerline {
  include repository
  require python

  $powerline_repo = "${boxen::config::datadir}/powerline"
  $fonts_installed_sentinal = '/var/db/.puppet_powerline_fonts_git'

  repository{
    $powerline_repo:
      source   => 'Lokaltog/powerline',
      provider => 'git';
    "${powerline_repo}-fonts":
      source   => 'Lokaltog/powerline-fonts',
      provider => 'git';
  }

  file{
    "/Users/${::boxen_user}/Library/Fonts":
      ensure => directory;
    "${boxen::config::envdir}/powerline.sh":
      content => template('powerline/powerline.sh.erb');
  }

  # Has to be installed to the global python location
  exec {
    'install powerline':
      cwd     => "${powerline_repo}/powerline",
      command  => ". ${boxen::config::home}/env.sh && \
        pip install -e .",
      provider => 'shell',
      user     => $::boxen_user,
      require => Repository[$powerline_repo],
      creates => "${homebrew::config::installdir}/lib/python2.7/site-packages/Powerline.egg-link";
    'install powerline fonts to user':
      cwd     => "${powerline_repo}-fonts",
      path    => '/usr/bin',
      command => "rsync -aPv */*.[ot]tf ~${::boxen_user}/Library/Fonts/",
      require => [Repository["${powerline_repo}-fonts"], File["/Users/${::boxen_user}/Library/Fonts"]],
      creates => $fonts_installed_sentinal,
      notify  => [Exec["touch ${fonts_installed_sentinal}"],
                  Notify['powerline-font notice']];
    "touch ${fonts_installed_sentinal}":
      command => "/usr/bin/touch ${fonts_installed_sentinal}";
  }

  notify{'powerline-font notice':
    message => 'Powerline has been installed, but your fonts are going to be screwed up! You need to modify your \
    terminal preferences to select one of the Powerline fonts, such as AnonymousPro'
  }

  #TODO: Require janus, but what happens with vimrc.after?
  # convert to params? if so see file_line support from stdlib
  # or use the puppet-concat module and let it add things in that way...

  #TODO: Add tmux set -g support?
  # convert to params? if so see file_line support from stdlib
  # or use the puppet-concat module and let it add things in that way...

}
