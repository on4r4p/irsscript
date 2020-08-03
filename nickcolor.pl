use strict;
use Irssi 20020101.0250 ();
use vars qw($VERSION %IRSSI); 
$VERSION = "2";
%IRSSI = (
    authors     => "Timo Sirainen, Ian Peters, David Leadbeater",
    contact	=> "tss\@iki.fi", 
    name        => "Nick Color",
    description => "assign a different color for each nick",
    license	=> "Public Domain",
    url		=> "http://irssi.org/",
    changed	=> "Sun 15 Jun 19:10:44 BST 2014",
);

# Settings:
#   nickcolor_colors: List of color codes to use.
#   e.g. /set nickcolor_colors 2 3 4 5 6 7 9 10 11 12 13
#   (avoid 8, as used for hilights in the default theme).

my %saved_colors;
my %session_colors = {};

sub load_colors {
  open my $color_fh, "<", "$ENV{HOME}/.irssi/saved_colors";
  while (<$color_fh>) {
    chomp;
    my($nick, $color) = split ":";
    $saved_colors{$nick} = $color;
  }
}

sub save_colors {
  open COLORS, ">", "$ENV{HOME}/.irssi/saved_colors";

  foreach my $nick (keys %saved_colors) {
    print COLORS "$nick:$saved_colors{$nick}\n";
  }

  close COLORS;
}

# If someone we've colored (either through the saved colors, or the hash
# function) changes their nick, we'd like to keep the same color associated
# with them (but only in the session_colors, ie a temporary mapping).

sub sig_nick {
  my ($server, $newnick, $nick, $address) = @_;
  my $color;

  $newnick = substr ($newnick, 1) if ($newnick =~ /^:/);

  if ($color = $saved_colors{$nick}) {
    $session_colors{$newnick} = $color;
  } elsif ($color = $session_colors{$nick}) {
    $session_colors{$newnick} = $color;
  }
}

# This gave reasonable distribution values when run across
# /usr/share/dict/words

sub simple_hash {
  my ($string) = @_;
  chomp $string;
  my @chars = split //, $string;
  my $counter;

  foreach my $char (@chars) {
    $counter += ord $char;
  }

  my @colors = split / /, Irssi::settings_get_str('nickcolor_colors');
  $counter = $colors[$counter % @colors];

  return $counter;
}

sub sig_public {
  my ($server, $msg, $nick, $address, $target) = @_;

  # Has the user assigned this nick a color?
  my $color = $saved_colors{$nick};

  # Have -we- already assigned this nick a color?
  if (!$color) {
    $color = $session_colors{$nick};
  }

  # Let's assign this nick a color
  if (!$color) {
    $color = simple_hash $nick;
    $session_colors{$nick} = $color;
  }

  $color = sprintf "\003%02d", $color;
  $server->command('/^format pubmsg {pubmsgnick $2 {pubnick ' . $color . '$0}}$1');
}

sub cmd_color {
  my ($data, $server, $witem) = @_;
  my ($op, $nick, $color) = split " ", $data;

  $op = lc $op;

  if (!$op) {
    Irssi::print ("No operation given (save/set/clear/list/preview)");
  } elsif ($op eq "save") {
    save_colors;
  } elsif ($op eq "set") {
    if (!$nick) {
      Irssi::print ("Nick not given");
    } elsif (!$color) {
      Irssi::print ("Color not given");
    } elsif ($color < 2 || $color > 14) {
      Irssi::print ("Color must be between 2 and 14 inclusive");
    } else {
      $saved_colors{$nick} = $color;
    }
  } elsif ($op eq "clear") {
    if (!$nick) {
      Irssi::print ("Nick not given");
    } else {
      delete ($saved_colors{$nick});
    }
  } elsif ($op eq "list") {
    Irssi::print ("\nSaved Colors:");
    foreach my $nick (keys %saved_colors) {
      Irssi::print (chr (3) . "$saved_colors{$nick}$nick" .
		    chr (3) . "1 ($saved_colors{$nick})");
    }
  } elsif ($op eq "preview") {
    Irssi::print ("\nAvailable colors:");
    foreach my $i (2..15) {
      Irssi::print (chr (3) . "$i" . "Color #$i");
    }
  }
}

load_colors;

#Irssi::settings_add_str('misc', 'nickcolor_colors', '2 3 4 5 6 7 9 10 11 12 13 14 15 17 18 21 23 25 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 86 87 92 93 94 95 96 97 98 99 100 101 102 103 104 105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 122 123 124 125 126 127 128 129 130 131 132 133 134 135 136 137 138 139 140 141 142 143 144 145 146 147 148 149 150 151 152 153 154 155 156 157 158 159 170 180 210 230 250');
Irssi::settings_add_str('misc', 'nickcolor_colors', '2 3 4 5 6 7 9 10 11 12 13 14 15');
Irssi::command_bind('color', 'cmd_color');

Irssi::signal_add('message public', 'sig_public');
Irssi::signal_add('event nick', 'sig_nick');
