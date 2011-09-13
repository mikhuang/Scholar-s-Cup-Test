group { "puppet":
    ensure => "present",
}



$mysql_root_password = ''


stage { "pre": before => Stage["main"] }				    
class python {
	package {							       
		"build-essential": ensure => latest;				
		"python": ensure => present;			       
		"python-dev": ensure => present;			   
		"python-setuptools": ensure => latest;
	}   
	exec { "easy_install pip":					      
		path => "/usr/local/bin:/usr/bin:/bin",			     
		refreshonly => true,						
		require => Package["python-setuptools"],			    
		subscribe => Package["python-setuptools"],			  
	}
	exec { "apt-get update":
  command => "/usr/bin/apt-get update && touch /tmp/apt.update",
  onlyif => "/bin/sh -c '[ ! -f /tmp/apt.update ] || /usr/bin/find /etc/apt -cnewer /tmp/apt.update | /bin/grep . > /dev/null'",
  }
	# source control
	package {
	   'git-core': ensure => latest;
	   'mercurial': ensure => latest;
	}					       
}									   
class { "python": stage => "pre" }



class djangobasics {
    package {
        "django":
            ensure   => "1.3.1",
            provider => pip;
        "libmysqlclient-dev":
            ensure => latest;
        "mysql-python":
            ensure => "1.2.3",
            provider => pip,
            require => Package["libmysqlclient-dev"];
    }

    # static file directories
    file {
        '/usr/local/share/wsgi/project/static':
            ensure  => directory,
            mode    => 0666,
            owner   => www-data
    }
    
    file {
        '/usr/local/share/wsgi/project/media':
            ensure  => directory,
            mode    => 0666,
            owner   => www-data
    }
    
    # TODO: syncdb, migrate?
    
    # 3rd party apps
    package { "fabric":
    	ensure => "latest",
    	provider => pip,
    }
    
    package { "south":
    	ensure => "0.7.3",
    	provider => pip,
    }
    
    package { "django-extensions":
    	ensure => "latest",
    	provider => pip,
    }
    
    package { "django-fiber":
    	ensure => "latest",
    	provider => pip,
    }
    
    package { "PIL":
    	ensure => "latest",
    	provider => pip,
    }
    
    package { "werkzeug":
    	ensure => present,
    	provider => pip,
    }
    
    #package { "django-allauth":
    #package { "git+http://github.com/pennersr/django-allauth.git":
    #	ensure => "latest",
    #	provider => pip,
    #}
    
    # should be in requirements for django-allauth, not sure why it didn't install
    #package { "git+http://github.com/facebook/python-sdk.git#egg=facebook-sdk":
    #    ensure => 'latest',
    #    provider => pip,
    #}
    
    package { "python-dateutil":
        ensure => '1.5',
        provider => pip,
    }
    
}

class sqlite {
    package {
        "sqlite3": 
            ensure  => latest;
    }
    file {
        '/usr/local/share/wsgi/project/db':
            ensure  => directory,
            mode    => 0666,
            owner   => www-data
    }
    file {
        '/usr/local/share/wsgi/project/db/db.sqlite':
            ensure  => present,
            mode    => 0666,
            owner   => www-data
    }
}

include sqlite
include apache2
#include mysql
include djangobasics