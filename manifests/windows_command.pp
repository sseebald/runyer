# Simply installs the Mcollective agent on the master and nodes.
# No spaces allowed in $action_name (defaults to $title) to keep filename and mco/LM sane.

define runyer::windows_command (
  $command, # the command to run
  $description = "Runs ${command} on windows agents",
  $action_name = $title,
  $ensure      = 'present' # 'present' or 'absent'
  ) {

  validate_re($action_name, '^\S*$', '$action_name param may not contain spaces')
  validate_re($ensure, ['present', 'absent'], '$ensure param must be \'absent\' or \'present\'')
  $ddl_file    = template('runyer/win_ddl.erb')
  $rb_file     = template('runyer/win_rb.erb')
   
  if $::kernel == 'windows' {

    file { "C:/ProgramData/PuppetLabs/mcollective/etc/plugins/mcollective/agent/${action_name}.ddl":
      ensure  => $ensure,
      mode    => '0644',
      content => $ddl_file,
      notify  => Service['pe-mcollective'],
    }

    file { "C:/ProgramData/PuppetLabs/mcollective/etc/plugins/mcollective/agent/${action_name}.rb":
      ensure  => $ensure,
      mode    => '0644',
      content => $rb_file,
      notify  => Service['pe-mcollective'],
    }

  }

  # For the Puppet Enterprise Master server
  elsif $::kernel == 'Linux' and
    ($settings::server == $::fqdn or
     $settings::server == $::hostname or
     $settings::server == $::ec2_hostname)
  {

    file { "/opt/puppet/libexec/mcollective/mcollective/agent/${action_name}.ddl":
      ensure  => $ensure,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => $ddl_file,
      notify  => Service['pe-mcollective'],
    }

    file { "/opt/puppet/libexec/mcollective/mcollective/agent/${action_name}.rb":
      ensure  => $ensure,
      owner   => root,
      group   => root,
      mode    => '0644',
      content => $rb_file,
      notify  => Service['pe-mcollective'],
    }

  }

  else {
    notify { "runyer::windows_command ${action_name} only supported on Linux master and Windows agent nodes": }
  }

}
