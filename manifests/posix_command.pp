# Simply installs the Mcollective agent on the master and nodes.
# No spaces allowed in $action_name (defaults to $title) to keep filename and mco/LM sane.

define runyer::posix_command (
  $command, # the command to run
  $description = "Runs ${command} on posix agents",
  $action_name = $title,
  $ensure      = 'present' # 'present' or 'absent'
  ) {

  validate_re($action_name, '^\S*$', '$action_name param may not contain spaces')
  validate_re($ensure, ['present', 'absent'], '$ensure param must be \'absent\' or \'present\'')
  $ddl_file    = template('runyer/posix_ddl.erb')
  $rb_file     = template('runyer/posix_rb.erb')

  # For the Unix/Linux agents and the Puppet Enterprise Master Linux server
  if $::kernel != 'windows' {

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
    notify { "runyer::posix_command ${action_name} only supported on Linux master and Unix/Linux agent nodes": }
  }

}
