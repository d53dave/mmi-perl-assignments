#!/usr/bin/perl -w
use strict;
use warnings;
use Tk;
use Tk::LabFrame;

my $mw = MainWindow->new(-title => 'Perl Mini Regex Tester');

my $txtlabframe = $mw->LabFrame(
    -label => 'Target Text',
    -labelside => 'acrosstop',
	)->pack(-side   => 'bottom',
            -expand => 1,
            -fill   => 'both',
           );
           
my $regexlabframe = $mw->LabFrame(
    -label => 'Regex',
    -labelside => 'acrosstop',
	)->pack(-side   => 'top',
            -fill   => 'x',
           );

my $regexentry = $regexlabframe ->Text(-height => 1,-background => 'white')->pack(-side =>
'top', -fill => 'x',);
           


my $txt = $txtlabframe->Scrolled ( 'Text',
                         -width => 50,
                         -height => 10,
                         -relief => 'sunken',
                         -scrollbars => "osoe",
                         -background => 'white',
                         -wrap => 'none' ) -> pack(-side => 'bottom', -fill => 'both', -expand => 1);


$txt->tagConfigure('foundtag',-foreground => "white", -background => "blue");

$regexentry->bind('<KeyPress>' => sub { highlightText() });
$txt->bind('<KeyPress>' => sub { highlightText() });
MainLoop;

sub highlightText
{	
	my $regexinput = $regexentry->get('1.0','end-1c');
	$txt->tagRemove('foundtag', '1.0', 'end');
	
	if($regexinput)
	{
		my $result = eval 
		{
			my $regex = eval { qr/$regexinput/ }; #check regex for errors
			unless ($@){ #if the eval raised no errors, this block will be executed
				$txt->FindAll(-regexp,-case, $regex);
				$regexentry->configure(-background => 'white');
				if ($txt->tagRanges('sel')) 
				{
					my %startfinish  = $txt->tagRanges('sel');
					foreach(sort keys %startfinish) 
					{
						$txt->tagAdd("foundtag", $_, $startfinish{$_});
					}
				$txt->tagRemove('sel', '1.0', 'end');
				}
			} else { #will be executed if the eval block raised an error
				$regexentry->configure(-background => 'red'); 
			}
		}; 
	}
}
