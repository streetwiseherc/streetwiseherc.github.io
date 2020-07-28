print "Content-type: text/html\n\n";

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

sub validate_data
{
  if (($who eq "") || ($artist eq "") || ($title eq ""))
  {
    print q~
    <CENTER><IMG SRC="..\Images\error.gif" HEIGHT=24 WIDTH=318 ALT="An Error Occured"></CENTER>
    <P>
    The form was not completely filled out. Please fill in the Song, Artist, and your Name.  If you would like to hear any song from a particular artist or any song from a particular cd from a particular artist, please specify "Any Song" or "Any Song from 'Album Name' " respectively. 
    ~;
    $valid_data = 0;
  }
  else
  {
    print qq~
      <CENTER><IMG SRC=\"..\\Images\\thanks.gif\" HEIGHT=29 WIDTH=434 ALT="Thanks for the Request"></CENTER>
      <P>
      Your request was recieved and will be played as soon as possible.  In the event that we are unable to play your request due to lack of time, we will make an extra attempt to play it next week.  If we are unable to fill the request because it is not in our extensive cd library, we apologize and encourage you to make another request.  Remember young Skywalker, only you can keep the phat beats alive.<P>
      Your request was recieved as:
      <PRE>
        artist:    <B>$artist</B>
        song:      <B>$title</B>   
        comments:  <B>$comments</B> 
        your name: <B>$who</B>
      </PRE>      
    ~;
    $valid_data = 1;
  }
}

sub html_begin
{

print q~
<HTML>
<HEAD>
<TITLE>the Metropolis Project: Thanks for the Request!</TITLE>
</HEAD>
<BODY BGCOLOR="#000000" LINK="#66CC66" VLINK="#DDDDDD" ALINK="#EEEEEE" TEXT="#DDDDDD" TOPMARGIN=0 LEFTMARGIN=0>
<FONT FACE="Arial" SIZE=3> 
&nbsp;<BR>
<CENTER><A HREF="http://mcs.uww.edu/students/ekinated/MetropolisProject/index.htm"><IMG WIDTH=419 HEIGHT=151 ALT="the Metropolis Project featuring DC Zero and DJ Six Million Dollar" SRC="..\Images\NewLogo.gif" BORDER=0></A></CENTER>
<P>
<CENTER>
<TABLE BORDER=0 WIDTH=500>
  <TR>
    <TD>
~;

}

sub html_end
{

print q~
    </TD>
  </TR>
</TABLE>
<P>
Return to <A HREF="http://mcs.uww.edu/students/ekinated/MetropolisProject/index.htm#requests">the Metropolis Project</A><BR>
</CENTER>
<BR>
</BODY>
</HTML>
~;

}

sub host_info
{

  $remote_host_ip   = $ENV{'REMOTE_ADDR'};
  $remote_host_name = $ENV{'REMOTE_HOST'};

  if ($remote_host_name eq $remote_host_ip )
  {  
    $address = pack("C4",split(/\./,$remote_host_ip));
    ($host,$aliases,$type,$length,@addrs) = gethostbyaddr($address,AF_INET);
    $remote_host_name = $host;
  }
  
}

sub mail_request
{

  $mail_server = 'uwwvax.uww.edu';
  $mail_to = 'MetropolisProject@netscape.net';
  $mail_from = 'OnlineRequest@uwwvax.uww.edu';                                
  $mail_subject = 'Online Request';                               
  $mail_message = "$who from $remote_host_name ($remote_host_ip)\n  requested:\n            artist: $artist\n              song: $title\n   comments:\n  $comments";
  $mail_date = localtime;
  $mail_header ="Date: $mail_date\nFrom: $mail_from\nSubject: $mail_subject\nTo: $mail_to\n\n";

  $port = 25;
  $AF_INET = 2;
  $SOCK_STREAM = 1;

  $sockaddr = 'S n a4 x8';

  $localhost = $ENV{'SERVER_NAME'};

  ($name,$aliases,$proto) = getprotobyname('tcp');
  ($name,$aliases,$port) = getservbyname($port,'tcp') unless $port =~ /^\d+$/;;
  ($name,$aliases,$type,$len,$localaddr) = gethostbyname($localhost);
  ($name,$aliases,$type,$len,$remoteaddr) = gethostbyname($mail_server);


  $local = pack($sockaddr, $AF_INET, 0, $localaddr);
  $remote = pack($sockaddr, $AF_INET, $port, $remoteaddr);

  socket(S,$AF_INET, $SOCK_STREAM, $proto);
  connect(S,$remote);

  select(S);
  $| = 1;
  select(STDOUT);
  
  recv(S,$server_response,255,0);

  send (S,"EHLO $localhost\n",0); 
  recv(S,$server_response,255,0);

  send (S,"MAIL FROM:<$mail_from>\n",0); 
  recv(S,$server_response,255,0);
  
  send (S,"RCPT TO:<$mail_to>\n",0); 
  recv(S,$server_response,255,0);

  send (S,"DATA\n",0); 
  recv(S,$server_response,255,0);

  send (S,$mail_header,0); 
  send (S,"$mail_message\n.\n",0); 
  recv(S,$server_response,255,0);

  send (S,"QUIT\n",0); 
  recv(S,$server_response,255,0);

  close S;
}

#MAIN SUB

parse_cgi;

$who = $user_data{'request_who'};
$artist = $user_data{'request_artist'};
$title = $user_data{'request_title'};
$comments = $user_data{'request_comments'};

html_begin;

validate_data;

if ($valid_data == 1)
{
  host_info;
  mail_request;
}

html_end;