use strict;
use vars qw($VERSION %IRSSI);

$VERSION = '0.02';
%IRSSI = (
    authors     => 'On4r4p',
    contact	=> '#####@somewhere.yep',
    name        => 'autostuff',
    description	=> 'Save current servers, channels and windows for autoconnect and autojoin',
    license	=> 'Public Domain',
    url		=> '127.0.0.1',
   changed	=> 'now',
);

use Irssi qw(command_bind servers channels windows command);

sub saveserv {
    my ($data, $server, $window) = @_;
    my ($adresse) = "";
    my ($chan) = "";
    my ($glue) = "";
    my $superglue3 = "";
    my ($check) = "0";
    my $chatnet1 = $_->{chatnet} || $_->{tag}; 
    my $chatnet2 = $_->{server}->{chatnet} || $_->{server}->{tag};
    for (servers) {
        my $chatnet1 = $_->{chatnet} || $_->{tag};
        #command "/network add $chatnet";
        #command "/server add -auto -network $chatnet $_->{address} $_->{port} $_->{password}";
        #Irssi::print("$chatnet1 $_->{address} $_->{port} $_->{password}");
        $adresse = "$chatnet1 $_->{address}";
    }
    for (channels) {
        my $chatnet2 = $_->{server}->{chatnet} || $_->{server}->{tag};
        #command "/channel add -auto $_->{name} $chatnet $_->{key}";
        #Irssi::print("$_->{name} $chatnet2 $_->{key}");
        $chan = "$chatnet2 $_->{name}";
     
     $glue = "$adresse $chan";
     my (@glued) = split / /,$glue;
     $superglue3 = "$glued[1] $glued[3]";
     
     #Irssi::print($superglue3);

     my $filename = '~/.irssi/scripts/connected.already';
     open(my $fh, '<:encoding(UTF-8)', $filename)
     or die "Could not open file '$filename' $!";
     while (my $row = <$fh>) {
          chomp $row;

          if ($row eq $superglue3) {
             #print "row : $row et superglu $superglue3";
             $check = "1";
          }
          else {
#             print "not found\n";
#             print "Glue = $glue";
#             print "Row = $row";

          }

          }
     close $fh;
     }
     if ($check eq "0") {
          open(my $fh, '>>', '~/.irssi/scripts/connected.already');
          Irssi::print("\nSaving server and channels.\n");
          print $fh "$superglue3\n";
          close $fh;
     }else{
          Irssi:print("\nAlready saved\n");
     }

    
};

Irssi::signal_add_last('event join', 'saveserv');

