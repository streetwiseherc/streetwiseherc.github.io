#! /usr/local/bin/perl

#////////////////////////////////////////////////////////////////////

sub parse_cgi
{
  local(@name_value_pairs,$name_value_pair,$user_string,$name,$value);

  if ($ENV{'REQUEST_METHOD'} eq "POST")
  {    
    read(STDIN,$user_string,$ENV{'CONTENT_LENGTH'});
  }
  else
  {    
    $user_string = $ENV{'QUERY_STRING'}
  }

  $user_string =~ s/\+/ /g;
  @name_value_pairs = split(/&/, $user_string);

  foreach $name_value_pair(@name_value_pairs)
  {    
    ($name,$value) = split(/=/, $name_value_pair);
    $name  =~ s/%([a-fA-f0-9][a-fA-f0-9])/pack("C",hex($1))/ge;
    $value =~ s/%([a-fA-f0-9][a-fA-f0-9])/pack("C",hex($1))/ge;
    $value =~ s/<!--(.|\n)*-->//g; 
    $value =~ s/<([^>]|\n)*>//g;   
    $user_data{$name} = $value;
  }
}

#////////////////////////////////////////////////////////////////////

print "Content-type: text/html\n\n";

#////////////////////////////////////////////////////////////////////

parse_cgi;

$playlist_file = join("","C:\\webpages\\students\\ekinated\\metrop~1\\playli~1\\",$user_data{'playlist'},".txt");

#////////////////////////////////////////////////////////////////////

if (!open(PLAYLIST,$playlist_file))
{
  print qq~
  <HTML>
  <HEAD><TITLE>Error Opening Playlist: $user_data{'playlist'}</TITLE></HEAD>
  <BODY>
  <PRE>
  Script Error:
  Could not open $user_data{'playlist'}.
  ~;

# put some date checking here!!!

  print qq~
  </PRE>
  <CENTER><FORM><INPUT type=button value='Close Window' onClick='self.close()'></FORM></CENTER>
  </BODY>
  </HTML>
  ~;
  exit;
}

@PlaylistData = <PLAYLIST>;

close(PLAYLIST);

print qq~
  <HTML>
  <HEAD>
  <TITLE>Metropolis Project: Playlist for $PlaylistData[0]</TITLE>
  </HEAD>
  <BODY>
  <PRE>
<B>$PlaylistData[0]</B>
<B>Show Comments:</B>
<I>
~;

# print next lines until "#" 
for ($i = 1; $PlaylistData[$i] ne "#\n"; $i++)
{
  chop($PlaylistData[$i]);
  if ($PlaylistData[$i] ne "")
  {
    print "$PlaylistData[$i]\n"; 
  }
}

$i++;

print qq~
  </I><B>
Show Playlist:
</B><B>
~;
print sprintf("%-35s","CD");
print sprintf("%-35s","Artist");
print sprintf("%-35s","Song");
print "\n</B>";

# print songs until eof
while ($i <= $#PlaylistData)
{
  chop($PlaylistData[$i]);
  ($cd,$artist,$song) = split(';',$PlaylistData[$i]);
  print sprintf("%-35s",$cd);
  print sprintf("%-35s",$artist);
  print sprintf("%-35s\n",$song);
  $i++;
}

print qq~
    </PRE>
  <CENTER><FORM><INPUT type=button value='Close Playlist' onClick='self.close()'></FORM></CENTER>
  </BODY>
  </HTML>
~;

#////////////////////////////////////////////////////////////////////

