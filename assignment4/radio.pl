#!/usr/bin/perl -w
use strict;
use warnings;
use Tk;
use Tk::LabFrame;

my %radio_state = (
    "power"  => 0,
    "volume" => 0,
    "freq"  => 0,
    "carrier" => "",
    "stations" => {
		"LW" => {'207.0' => "Deutschlandfunk", '225.0' => "Polskie Radio Jedynka"},
		"UKW" => {'87.8'=> "\x{00D6}1", '89.9' => "\x{00D6}2 Radio Wien",  '92.9'=> "Radio Arabella", '101.3'=>"Hitradio \x{00D6}3", '105.8'	 => "KRONEHIT"},
		"MW" => {'540.0' => "MR1 Kossuth Radio", '1188.0' => "MR4 Nemzetisegi adasok"}
	},
    "record" => 0,
);

my $mw = MainWindow->new;
$mw->minsize(550,240);
$mw->title("MMI Radio");
my $displayframe = $mw->Frame()->pack(-side => 'top',
            -expand => 1,
            -fill   => 'both',
           );
my $controlframe = $mw->LabFrame(-label => 'Controls')->pack( -side => 'bottom',
            -expand => 1,
            -fill   => 'both',
           );
my $freqframe = $controlframe->Frame()->pack(-side => 'left',
            -expand => 1,
            -fill   => 'both',
           );
my $freqbuttonframe = $freqframe->Frame()->pack(-side => 'top',
            -expand => 1,
            -fill   => 'both',
           );
my $recordframe = $controlframe->Frame()->pack(-side => 'right',
            -expand => 1,
            -fill   => 'both',
           );
my $recbuttonframe = $recordframe->Frame()->pack(-side => 'top',
            -expand => 1,
            -fill   => 'both',
           );
my $onoff = $displayframe->Button(-text => 'I/O', -command => \&togglePower)
->pack(-side =>'right',-anchor => 'ne', -padx => 10,
			-pady => 10,
           );
my $display = $displayframe->Text(-height => 5, 
			-width => 30, 
			-borderwidth => 2,
			-padx => 10,
			-pady => 10,
			-relief => 'solid',
			-state => 'disabled',
			)->pack(-side   => 'left',-anchor => 'nw', -padx => 10,
			-pady => 10,
           );
my $lwbutton = $freqbuttonframe->Button(-text => ' LW ', -state => 'disabled', -command => sub {
	carrierSelect("lw");
}
)
->pack(-side => 'left',-expand => 1
           );
my $mwbutton = $freqbuttonframe->Button(-text => ' MW ', -state => 'disabled', -command => sub {
	carrierSelect("mw");
}
)
->pack(-side => 'left',-expand => 1
           );
my $ukwbutton = $freqbuttonframe->Button(-text => 'UKW', -state => 'disabled', -command => sub {
	carrierSelect("ukw");
}
)
->pack(-side => 'left', -expand => 1
           );
my %carrier_buttons = (
'ukw' => $ukwbutton, 'mw' => $mwbutton, 'lw' => $lwbutton,
);

my $labeltext = "______________________\nFrequency";
my $freqlabel = $freqframe->Label(-text => $labeltext)->pack( );
my $freqslider = $freqframe->Scale(-from => 0, -to => 500, -orient => 'horizontal', -state => 'disabled', -resolution => .1, -command => \&changeSlider)->pack(-side => 'top', -fill => 'both',
                                            -expand => 0, -anchor => 's'
           );

$recordframe->Label(-text => "______________________\nVolume")->pack( );
my $volumeslider = $recordframe->Scale(-from => 0, -to => 10, -orient => 'horizontal', -state => 'disabled', -resolution => .1, )->pack(-side => 'top', -fill => 'both',
                                            -expand => 0, -anchor => 's'
           );
$volumeslider->bind('<ButtonRelease-1>' => sub {
	changeSlider();
}
);
my $recbutton = $recbuttonframe->Button(-text => 'Record', -state => 'disabled', -command => \&record)
->pack(-side => 'left', -expand => 1
           );
MainLoop;
sub updateDisplay() {
	$display->configure(-state => 'normal',);
	$display->delete("1.0", 'end');
	if($radio_state{power} == 1){
		my $carrier = $radio_state{carrier};
		my $freq = $radio_state{freq};
		my $station = $radio_state{stations}{$carrier}{$freq};
		$station = "White Noise..." if (!defined($station));

		$display->insert('end', "Awesome MMI Radio\n");
		$display->insert('end', "Tuned to Frequency $freq\n\n");
		$display->insert('end', "You are listening to: \n$station\n");
	}
	$display->configure(-state => 'disabled',);
}
sub togglePower() {
	if($radio_state {power} == 0) {
		$radio_state {power} = 1;
		$onoff->configure(-bg => '#5ABDFA', -activebackground => '#5ABDFA', -highlightbackground => '#5ABDFA');
		$recbutton->configure(-state => 'active',);
		$recbutton->configure(-bg => 'grey', -activebackground => 'grey', -highlightbackground => 'grey');
		$volumeslider->configure(-state => 'active',);
		$freqslider->configure(-state => 'active',);
		while(my($k, $v) = each %carrier_buttons) {
			$v->configure(-state => 'active',);
			$v->configure(-bg => 'grey', -activebackground => 'grey', -highlightbackground => 'grey');
		}
		carrierSelect("ukw");
		$display->configure(-bg => '#5ABDFA');
	} else {
		$radio_state {power} = 0;
		$onoff->configure(-bg => 'grey', -activebackground => 'grey', -highlightbackground => 'grey');
		$recbutton->configure(-state => 'disabled',);
		$volumeslider->configure(-state => 'disabled',);
		$freqslider->configure(-state => 'disabled',);
		$radio_state {record} = 0;
		$recbutton->configure(-bg => 'grey', -activebackground => 'grey', -highlightbackground => 'grey');
		resetCarrierButtons("disable");
		$display->configure(-bg => 'grey');
	}
	updateDisplay();
}
sub changeSlider() {
	$radio_state {volume} = $volumeslider->get();
	$radio_state {freq} = $freqslider->get();
	updateDisplay();
}
sub carrierSelect() {
	my ($car) = @_;
	$radio_state {carrier} = 0;
	if($car eq "ukw") {
		$radio_state {"carrier"} = 'UKW';
		resetCarrierButtons("nodisable");
		$ukwbutton->configure(-bg => '#5ABDFA', -activebackground => '#5ABDFA', -highlightbackground => '#5ABDFA');
		$freqlabel->configure(-text => "${labeltext} [MHz]");
		$freqslider->configure(-from => 87.5, -to => 108.0, );
	}
	elsif($car eq "mw") {
		$radio_state {"carrier"} = 'MW';
		resetCarrierButtons("nodisable");
		$mwbutton->configure(-bg => '#5ABDFA', -activebackground => '#5ABDFA', -highlightbackground => '#5ABDFA');
		$freqlabel->configure(-text => "${labeltext} [KHz]");
		$freqslider->configure(-from => 526.5, -to => 1606.5, );
	}
	elsif($car eq "lw") {
		$radio_state {"carrier"} = 'LW';
		resetCarrierButtons("nodisable");
		$lwbutton->configure(-bg => '#5ABDFA', -activebackground => '#5ABDFA', -highlightbackground => '#5ABDFA');
		$freqlabel->configure(-text => "${labeltext} [KHz]");
		$freqslider->configure(-from => 148.5, -to => 283.5, );
	}
	updateDisplay();
}
sub resetCarrierButtons() {
	my ($disable) = @_;
	while(my($k, $v) = each %carrier_buttons) {
		if($disable eq "disable") {
			$v->configure(-state => 'disabled',);
		}
		$v->configure(-bg => 'grey', -activebackground => 'grey', -highlightbackground => 'grey');
	}
}
sub record() {
	if($radio_state {record} == 0) {
		$radio_state {record} = 1;
		$recbutton->configure(-bg => 'red', -activebackground => 'red', -highlightbackground => 'red');
	} else {
		$radio_state {record} = 0;
		$recbutton->configure(-bg => 'grey', -activebackground => 'grey', -highlightbackground => 'grey');
	}
	updateDisplay();
}
