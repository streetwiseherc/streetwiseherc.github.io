#! /usr/local/bin/perl

$log_file = 'C:\webpages\students\ekinated\metrop~1\log.txt';

if (!open(LOG,$log_file))
{
#setup header if this is the first time script being run
  open(LOG,">>$log_file");
  print LOG sprintf "%-27s","Date/Time";
  print LOG sprintf "%-32s","Host Name";
  print LOG sprintf "%-17s","Host IP";
  print LOG sprintf "%-50s\n","Browser";
  close(LOG);
}

$remote_host_ip   = $ENV{'REMOTE_ADDR'};
$remote_host_name = $ENV{'REMOTE_HOST'};
$remote_software  = $ENV{'HTTP_USER_AGENT'};
$remote_from      = $ENV{'HTTP_REFERER'};
$time = localtime; 

if ($remote_host_name eq $remote_host_ip ) 
{
  $address = pack("C4",split(/\./,$remote_host_ip));
  ($host,$aliases,$type,$length,@addrs) = gethostbyaddr($address,AF_INET);
  $remote_host_name = $host;
}

open(LOG,">>$log_file");
print LOG sprintf "%-27s",$time;
print LOG sprintf "%-32s",$remote_host_name;
print LOG sprintf "%-17s",$remote_host_ip;
print LOG sprintf "%-50s\n",$remote_software;
close(LOG);

print "Location: http://mcs.uww.edu/students/ekinated/MetropolisProject/Images/log.gif\n\n";

