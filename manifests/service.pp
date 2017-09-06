# Manage the Stunnel Service
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
# @author Nick Markowski <nmarkowswki@keywcorp.com>
#
class stunnel::service {

  if $facts['os']['name'] in ['RedHat','CentOS'] {
    file { '/etc/rc.d/init.d/stunnel':
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0750',
      content => file("${module_name}/stunnel.init"),
      notify  => Exec['stunnel_chkconfig_update']
    }

    exec { 'stunnel_chkconfig_update':
      command     => '/sbin/chkconfig --del stunnel; /sbin/chkconfig --add stunnel',
      refreshonly => true,
      before      => Service['stunnel']
    }

    service { 'stunnel':
      ensure     => 'running',
      hasrestart => true,
      hasstatus  => true,
      require    => File['/etc/rc.d/init.d/stunnel'],
    }
  }
  elsif $facts['os']['name'] in ['Debian','Ubuntu'] {
    file { '/etc/default/stunnel4':
      ensure  => 'present',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => file("${module_name}/stunnel.default"),
      tag     => 'firstrun',
      notify  => Service['stunnel4'],
    }

    service { 'stunnel4':
      ensure     => 'running',
      hasrestart => true,
      hasstatus  => true,
      tag        => 'firstrun'
    }
  }
  else {
    fail("OS Family '${facts['os']['family']}' not supported by ${module_name}")
  }
}
