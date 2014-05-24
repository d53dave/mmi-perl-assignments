#!/usr/bin/perl -w
use strict;
use warnings;
use WWW::Dict::Leo::Org;
use Data::Dumper;
use Tk;
use Storable;
use encoding 'utf8';
require Tk::LabFrame;
require Tk::LabEntry;
require Tk::FBox;

my $workingfile = 0;
my $leo = new WWW::Dict::Leo::Org();
my $lastterm = "";
my %datagroup = ();

my $mw = MainWindow->new;
$mw->configure(-menu => my $menubar = $mw->Menu);

my $file = $menubar->cascade(-label => '~File', -tearoff => 0);
my $edit = $menubar->cascade(-label => '~Edit', -tearoff => 0);
my $help = $menubar->cascade(-label => '~Help', -tearoff => 0);

$file->command(
    -label       => 'Open',
    -accelerator => 'Ctrl-o',
    -command 	 => sub {opendialog()},
    -underline   => 0,
);
$file->command(
    -label       => 'Load to Source Text',
    -accelerator => 'Ctrl-l',
    -command 	 => sub {loadfile()},
    -underline   => 0,
);
$file->separator;
$file->command(
    -label       => 'Save',
    -accelerator => 'Ctrl-s',
    -command 	 => sub {savefile(0)},
    -underline   => 0,
);
$file->command(
    -label       => 'Save As ...',
    -accelerator => 'Ctrl-a',
    -command 	 => sub {savefile(1)},
    -underline   => 1,
);
$file->separator;
$file->command(
    -label       => "Close",
    -accelerator => 'Ctrl-w',
    -underline   => 0,
    -command     => \&exit,
);
$help->command(
    -label       => "Help",
    -underline   => 0,
    -command     => \&printhelp,
);
$edit->command(
    -label       => "Placeholder",
    -underline   => 0,
    -command     => sub{print "called the placeholder"},
);

$mw->title('MMI Translator Helper');

my $textframe = $mw->Frame()->pack(-side   => 'top',
            -expand => 1,
            -fill   => 'both',
           );

my $lfsrc = $textframe->LabFrame(
    -label => 'Source Text',
    -labelside => 'acrosstop'
	)->pack(-side   => 'left',
            -expand => 1,
            -fill   => 'both',
           );

my $src = $lfsrc->Scrolled("Text", -width => 60, -scrollbars => "osoe",
	)->pack(-side   => 'left',
			-expand => 1,
            -fill   => 'both',);
            
#$src->bind('<<Selection>>' => sub {gettrans()});
$src->bind('<ButtonRelease-1>' => sub{gettrans()});
           
my $lfdest = $textframe->LabFrame(
    -label => 'Target Text',
    -labelside => 'acrosstop'
	)->pack(-side   => 'right',
            -expand => 1,
            -fill   => 'both',
           );
           
my $dest = $lfdest->Scrolled("Text", -width => 60, -scrollbars => "osoe",
	)->pack(-side   => 'right',
			-expand => 1,
            -fill   => 'both',);


my $lfhelper = $mw->LabFrame(
    -label => 'Helper',
    -labelside => 'acrosstop'
	)->pack(-side   => 'bottom',
            -expand => -1,
            -fill   => 'both',
           );
           
my $helper = $lfhelper->Scrolled("Text", -height => 15, -scrollbars => "osoe",
	)->pack(-side   => 'top',
			-expand => 1,
            -fill   => 'both',);  

my $popup = $mw->Menu(
    -menuitems => [
        [
            Button   => 'Insert Selected',
            -state   => "disabled",
            -command => sub {$dest->Insert($helper->getSelected." ");}
        ]
    ], -tearoff => 0,
);

$helper->menu($popup);

$helper->bind(
    "<Button1-ButtonRelease>",
    sub {
        local $@;
        my $state = defined eval { $helper->SelectionGet } ? 
            "normal" : "disable";
        $popup->entryconfigure(1, -state => $state)
    }
);      
           
MainLoop;

sub opendialog()
{
	my $tmp = $mw->FBox(-type => "open", -filter =>glob('*.tlh'))->Show();
	if(not $tmp) {return;}
	$workingfile = $tmp;
	open( my $input_fh, "<", $workingfile ) or die "Can't open $workingfile: $!";
	my @lines = <$input_fh>;
	my $stored = join('', @lines);
	eval($stored);
	$src->insert('end', $datagroup{'src'});
	$dest->insert('end', $datagroup{'dest'});
}

sub loadfile()
{
	my $load_file =  $mw->FBox(-type => "open")->Show();
	if(not $load_file) {return;}
	open( my $input_fh, "<", $load_file ) or die "Can't open $load_file: $!";
	while (<$input_fh>) 
	{
		$src->insert('end', $_);
	}
}

sub savefile()
{
	if($_[0] or not $workingfile)
	{
		my $tmp = $mw->FBox(-type => "save", -filter =>glob('*.tlh'))->Show();
		if(not $tmp) {return;}
		$workingfile = $tmp;
	}
	$datagroup{'src'} = $src->get("1.0", "end");
	$datagroup{'dest'} = $dest->get("1.0", "end");
	my $stored = Data::Dumper->Dump( [ \%datagroup ], [ qw(*datagroup )] );
	open(my $fh, '>', $workingfile);
	print $fh $stored;
	close $fh;
}

sub gettrans()
{
	my $word = $src->getSelected;
	if(length $word > 1 and not ($word eq $lastterm))
	{
		$lastterm = $word;
		$helper->delete("1.0", 'end');
		my @matches = $leo->translate($word);
		foreach(@matches)
		{
			my %match = %{$_};
			my $title = $match{'title'};
			my @data = $match{'data'};
			
			foreach(@data)
			{
				$helper->Insert($title);
				$helper->Insert("\n");
				foreach (@$_)
				{
					foreach my $entry ($_)
					{
						my $left = $entry->{'left'};
						my $right = $entry->{'right'};
						$helper->insert('end', "\t");
						$helper->insert('end', $left);
						$helper->insert('end', "\t");
						$helper->insert('end', $right);
						$helper->Insert("\n");
					} 
				}
					
			}
		}
	}
}

sub printhelp()
{
	$mw->messageBox(-message => "This is the help text.\nVery helpful, isn't it?", 
				-type => "Got it!", -title => "Help");
}
