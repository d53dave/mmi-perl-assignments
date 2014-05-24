#!/usr/bin/perl -w
use strict;
use Tk;
require Tk::LabFrame;
require Tk::LabEntry;

my $mw = MainWindow->new;

$mw->title('MMI Word Display');

#Labeled Frame for text entry
my $lf0 = $mw->LabFrame(
    -label => 'Text Entry',
    -labelside => 'acrosstop'
	)->pack(-side   => 'top',
            -expand => 1,
            -fill   => 'both',
           );

#Text entry widget  
my $entrytext = ''; 
my $entry = $lf0->LabEntry(-textvariable => \$entrytext)
	->pack(-side   => 'left',
            -expand => 1,
            -fill   => 'x',
            -ipadx => '150',
           );

#Button that triggers show action
$lf0->Button(-text => "Go!",
	-command => sub {show()},
	)->pack(-side   => 'right',
            -expand => 0,
            -fill   => 'none',
            -ipadx  => 20,
            -pady   => 2,
           );
           
#Bind return key to show action
$entry->bind('<Return>' => \&show);

#Labeled frame for display options
my $lf1 = $mw->LabFrame(
    -label => 'Display Options',
    -labelside => 'acrosstop'
	)->pack(-expand => 1,
			-fill   => 'both',
        );

#Labeled frame for word ordering option radiobuttons
my $lf1_0 = $lf1->LabFrame(
    -label => 'Word Ordering ',
    -labelside => 'left',
	)->pack(-expand => 1,
            -fill   => 'both');
#Labeled frame for output list radiobuttons
my $lf1_1 = $lf1->LabFrame(
    -label => 'Output List        ',
    -labelside => 'left'
	)->pack(-expand => 1,
            -fill   => 'both',
           );

#output box choice radiobuttons 
my $boxchoice = 0;
my $radio_box1 = $lf1_1->Radiobutton(-text => "Box 1", 
	-value => 0,
	-variable=> \$boxchoice
	)->pack(-side => "left");
	
my $radio_box2 = $lf1_1->Radiobutton(-text => "Box 2",
	-value => 1,
	-variable=> \$boxchoice
	)->pack(-side => "left");
	
my $radio_box3 = $lf1_1->Radiobutton(-text => "Box 3", 
	-value => 2,
	-variable=> \$boxchoice
	)->pack(-side => "left");

#word ordering choice radiobuttons	
my $reverse = 0;
my $radio_order1 = $lf1_0->Radiobutton(-text => "Normal", 
	-value => 0,
    -variable=> \$reverse
    )->pack(-side => "left");
    
my $radio_order2 = $lf1_0->Radiobutton(-text => "Reverse",
	-value => 1,
    -variable=> \$reverse
    )->pack(-side => "left");
           
#Labeled frame for output area
my $lf2 = $mw->LabFrame(
    -label => 'Output',
    -labelside => 'acrosstop'
	)->pack(-side   => 'bottom',
            -expand => 100,
            -fill   => 'both',
           );
           
#Output listboxes       
my $listbox0  = $lf2->LabFrame(
    -label => 'Box 1',
    -labelside => 'top'
	)->pack(-side => 'left',
			-expand => 1,
            -fill => 'both',
           )->Scrolled("Listbox", #Listbox inside scrolled
							-scrollbars => "osoe",
                            -width => -1,       
                            -setgrid => 1,
                            -selectmode => 'single',
                           )->pack( -expand => 1,
									-fill => 'both',
									);
                           
my $listbox1  = $lf2->LabFrame(
    -label => 'Box 2',
    -labelside => 'top'
	)->pack(-side => 'left',
			-expand => 1,
            -fill   => 'both',
           )->Scrolled("Listbox",
				-scrollbars => "osoe",
				-width => -1,      
				-setgrid => 1,
				-selectmode => 'single',
				)->pack(-side => 'right',
					-expand => 1,
					-fill => 'both',
					);
					
my $listbox2  = $lf2->LabFrame(
	-label => 'Box 3', 
	-labelside => 'top')
		->pack(-side => 'left',
				-expand => 1,
				-fill => 'both',
				)->Scrolled("Listbox", 
					-scrollbars => "osoe",
					-width => -1,       
                    -setgrid => 1,
                    -selectmode => 'single',
                    )->pack(-expand => 1,
                            -fill => 'both',
                           );
MainLoop;

sub show {
	#clear boxes
	$listbox0->delete(0, 'end');
	$listbox1->delete(0, 'end');
	$listbox2->delete(0, 'end');
	my $text = $entry->get;
	if ($text eq ""){
		$mw->messageBox(-message => "You did not enter any text", 
				-type => "Ok", -icon => "error", -title => "Error");
	}
	$text =~ s/\h+/ /g;
	my @words = split / /, $text;
	if($reverse) {
		@words = reverse @words
	}
	if($boxchoice == 0) {
		$listbox0->insert('end', @words);
	}
	elsif($boxchoice == 1) {
		$listbox1->insert('end', @words);
	}
	elsif($boxchoice == 2) {
		$listbox2->insert('end', @words);
	}
}
