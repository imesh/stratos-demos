# Licensed to the Apache Software Foundation (ASF) under one
# or more contributor license agreements.  See the NOTICE file
# distributed with this work for additional information
# regarding copyright ownership.  The ASF licenses this file
# to you under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance
# with the License.  You may obtain a copy of the License at
# 
#   http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.

class tomcat(
  $owner   = 'root',
  $group   = 'root',
  $target  = '/mnt',
){

  $package_name    = "apache-tomcat-${tomcat_version}"
  $service_code    = 'apache-tomcat'
  $tomcat_home     = "${target}/${package_name}"

  tag($service_code)

  file { 
    "${tomcat_home}/conf/server.xml":
      ensure   => present,
      content  => template('tomcat/server.xml.erb'),
      require  => Exec['Extract tomcat package'];
  }
  
  file { 
    "${tomcat_home}/conf/context.xml":
      ensure  => present,
      content => template('tomcat/context.xml.erb'),
	  require  => Exec['Extract tomcat package'];
  }

  file {
    "/${target}/packs/apache-tomcat-${tomcat_version}.tar.gz":
      ensure => present,
      source => "puppet:///modules/tomcat/apache-tomcat-${tomcat_version}.tar.gz",
      require => File["${target}/packs"];
  }
  
  file {
    "${tomcat_home}/lib/mysql-connector-java-5.1.31-bin.jar":
      ensure => present,
      source => "puppet:///modules/tomcat/mysql-connector-java-5.1.31-bin.jar";
  }

  file { '/mnt/tomcat':
    content => template('tomcat/tomcat.erb'),
    require => File["${target}/packs"];
  }
  
  file { '/mnt/get_mysql_ip.py':
    ensure  => present,
    content => template('tomcat/get_mysql_ip.py.erb');
  }
  
  file { '/mnt/get_mysql_pwd.py':
    ensure  => present,
    content => template('tomcat/get_mysql_pwd.py.erb');
  }

  file { '/mnt/update_server_conf.sh':
    ensure  => present,
    content => template('tomcat/update_server_conf.sh.erb'),
	  mode    => '0755';
  }

  exec {
    'Extract tomcat package':
      path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      cwd       => $target,
      unless    => "test -d ${target}/${tomcat_home}/conf",
      command   => "tar xvfz ${target}/packs/${package_name}.tar.gz",
      logoutput => 'on_failure',
      creates   => "${target}/${tomcat_home}/conf",
      require   => File["/${target}/packs/apache-tomcat-${tomcat_version}.tar.gz"];
	
    'Set tomcat home permission':
      path      => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      cwd       => $target,
      command   => "chown -R ${owner} ${tomcat_home}; chmod -R 755 ${tomcat_home}",
      require   => [
        Exec['Extract tomcat package'],
        File["${tomcat_home}/conf/server.xml"],
		File["${tomcat_home}/conf/context.xml"],
      ];
  
    'Update server.xml' :
	  user       => $owner,
	  group      => $group,
      path    => "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
  	  command => "/bin/bash /mnt/update_server_conf.sh",
  	  require => [ File['/mnt/update_server_conf.sh'],
	               File['/mnt/get_mysql_ip.py'],
				   File['/mnt/get_mysql_pwd.py'],
	               Exec['Extract tomcat package'] ];

    'Start tomcat':
	  user       => $owner,
	  group      => $group,
      path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      cwd         => "${tomcat_home}/bin",
      environment => 'JAVA_HOME=/opt/java',
      command     => 'bash startup.sh',
      logoutput   => 'on_failure',
	  require     => [
	                   Exec['Update server.xml'],
                       Exec['Set tomcat home permission'] ];
  }
}

