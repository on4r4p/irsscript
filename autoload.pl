use strict;
use vars qw($VERSION %IRSSI);

$VERSION = '0.02';
%IRSSI = (
    authors     => 'On4r4p',
    contact	=> '#####@some.where',
    name        => 'autoload',
    description	=> 'Load  servers, channelsfor autoconnect and autojoin',
    license	=> 'Public Domain',
    url		=> '**',
    changed	=> 'that moment',
);

use Irssi qw(command_bind servers channels windows command);

our $go = "0";
our $chan2join = "";
#our $firstpong = "0";
#command "/autoload";
command_bind autoload => sub {
    
     my @servlist = ();
     my $check = "0";
     my $filename2 = '~/.irssi/scripts/connected.save';
     my $filename = '~/.irssi/scripts/connected.already';
     open(my $fh, '<:encoding(UTF-8)', $filename)
     or die "Could not open file '$filename' $!";

     while (my $row = <$fh>) {
          chomp $row;
          push @servlist, "$row";

          }
     close $fh;

     open(my $fh2, '<:encoding(UTF-8)', $filename2)
     or die "Could not open file '$filename' $!";

     while (my $row2 = <$fh2>) {
          chomp $row2;

         if ($row2 ne ""){

              print $row2;
              if ($row2 ~~ @servlist and $check eq "0") {
                  print("\nAnother instance of Irssi is connected to $row2 .\n"); 
               }
               elsif ($check eq "0") {
               
                  $check = "1";
                  print "$row2 not found .\n";
                  my (@rowsplit) = split / /,$row2;
                  print "\nConnecting to $rowsplit[0]\n";
                  command "/connect $rowsplit[0]";
                  print "";
    
                  #Irssi::signal_add_last('server connected', 'isconnected($rowssplit[1])';

                  our $go = "1";
                  our $chan2join = $rowsplit[1];
                  #print "\nJoining $rowsplit[1]\n";
                  #command "/join $rowsplit[1]";
 

               }

          }

     }
};


sub isconnected
{

my ($server, $data, $nick, $address) = @_;
my(@datasplit) = split " ", $data;

#print "";
#Irssi:print("!!!!!");
#Irssi::print("@_");
#Irssi:print("data[0]: $datasplit[0],data[1]: $datasplit[1],data[2]: $datasplit[2]");
#Irssi:print("!!!!!");
#print "";

if ($datasplit[0] eq "PONG"){

     if ($go eq "1") {

#          if ($firstpong eq "1") {

               print "im connected";
               print "\nJoining $chan2join\n";
               $server->command("join $chan2join");
               #command "/join $chan2join";
               our $go = "0";
               #}
                    #else{
                    #our $firstpong = "1";
                    #}
          }
               
     }
};


#Irssi::signal_add_last('server connected', 'isconnected');

Irssi::signal_add("server event", 'isconnected');
Irssi::signal_add("1event", 'isconnected');
