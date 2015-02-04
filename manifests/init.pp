class powerline {
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

  $binding_path = $shell ? {
    bash => "bash/powerline.sh",
    zsh => "zsh/powerline.zsh",
    fish => "fish/powerline-setup.fish",
    tcsh => "tcsh/powerline.tcsh",
    default => "shell/powerline.sh"
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
      cwd     => "${powerline_repo}",
      command  => "env -i bash -c \"source ${boxen::config::home}/env.sh && \
        python setup.py install\"",
      provider => 'shell',
      user     => $::boxen_user,
      require => Repository[$powerline_repo],
      creates => "${homebrew::config::installdir}/bin/powerline-render";
    'install powerline fonts to user':
      cwd     => "${powerline_repo}-fonts",
      path    => '/usr/bin',
      command => "rsync -aPv */*.[ot]tf ~${::boxen_user}/Library/Fonts/",
      require => [Repository["${powerline_repo}-fonts"], File["/Users/${::boxen_user}/Library/Fonts"]],
      creates => $fonts_installed_sentinal,
      notify  => Exec["touch ${fonts_installed_sentinal}"];
    "touch ${fonts_installed_sentinal}":
      command => "/usr/bin/touch ${fonts_installed_sentinal}",
      user    => 'root';
  }

  notify{'powerline-font notice':
    message => 'Powerline has been installed, but your fonts are going to be screwed up! You need to modify your terminal preferences to select one of the Powerline fonts, such as AnonymousPro',
    subscribe => Exec['install powerline fonts to user'];
  }

  #TODO: Require janus, but what happens with vimrc.after?
  # convert to params? if so see file_line support from stdlib
  # or use the puppet-concat module and let it add things in that way...

  #TODO: Add tmux set -g support?
  # convert to params? if so see file_line support from stdlib
  # or use the puppet-concat module and let it add things in that way...

}
