class apache2 {
    package { 
        "apache2":
            ensure  => present;
        "apache2-mpm-worker":
            ensure => "present";
        "libapache2-mod-wsgi":
            ensure => "present";
    }

    file {
    	"/etc/apache2/sites-available/project":
    		content => template("apache2/project.erb"),
    		ensure => file,
    		require => Package["apache2-mpm-worker"];
    	"/etc/apache2/sites-enabled/001-project":
    		ensure => "/etc/apache2/sites-available/project",
    		require => Package["apache2-mpm-worker"];
    	"/etc/apache2/sites-enabled/000-default":
    		ensure => absent,
    		require => Package["apache2-mpm-worker"];
        "/usr/local/share/wsgi":
            ensure => directory;
        "/usr/local/share/wsgi/project":
            ensure => directory;
    	"/usr/local/share/wsgi/project/project.wsgi":
    		content => template("apache2/project.wsgi.erb"),
    		ensure => file;
    }
    
    service { "apache2":
    	enable => true,
    	ensure => running,
    	require => Package["apache2-mpm-worker"],
    	subscribe => [
    		Package[
    			"apache2-mpm-worker",
    			"libapache2-mod-wsgi"],
    		File[
    			"/etc/apache2/sites-available/project",
    			"/etc/apache2/sites-enabled/001-project",
    			"/etc/apache2/sites-enabled/000-default",
    			"/usr/local/share/wsgi/project/project.wsgi"]],
    }
}