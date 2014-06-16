#!/usr/bin/perl -w
use strict;
use warnings;
use Tk;
use Tk::LabFrame;
use Tk::LabEntry;
use Digest::SHA qw(sha256_hex);
use Tk::Clock;
use Tk::StrfClock;
use Data::Dumper;
use Tk::BrowseEntry;
$Data::Dumper::Indent = 1;

my $mw = MainWindow->new;
$mw->minsize(400,580);
$mw->title("TROFA Patient Care System");
my $mainframe = $mw->Frame()->pack(-side => 'top',
            -fill   => 'both',
           );
           $mainframe->gridColumnconfigure(0, -weight => 1);


my $loginframe = $mainframe->Frame();       
my $userframe = $mainframe->Frame();
my $patientframe = $mainframe->Frame();
my $prescriptionframe = $mainframe->Frame();
my $topframe = undef;

my %users = (
    "73475cb40a568e8da8a045ced110137e159f890ac4da883b6b17dc651b3a8049" => {login => 'doc1', name => 'Gregory House', function => 'physician'},
    "cc921e1511ff878ac7b27b188a2f263b907ed64fde556b967a4066b187608ca8" => {login => 'nurse1', name => 'Carmen Brown', function => 'nurse'},
    "801eff9f8d95d49299ae8e9fb04679009011f766df325a01b37642650eff7190" => {login => 'pharm1', name => 'Alexander Flemming', function => 'pharmacist'}, 
    );
    
my %patients = (
    "PA1234567"  => {name => 'Norman Normal', 
					 dob => '19.11.1956', 
					 diagnosis => 'syphillis', 
					 prescriptions => ['PR6789'],
					 notes => 'very unfriendly'
					},
    "PA1234568" => {name => 'Norman Normal', 
					 dob => '19.11.1956', 
					 diagnosis => 'syphillis', 
					 prescriptions => ['PR6789'],
					 notes => 'very unfriendly'
					},
    );
    
my %prescriptions = (
	'PR6789' => [
						{drug => "DR3456", 
						 'time' => {code => 'daily', modifier => 3}, 
						}, 
						{drug => "DR3459", 
						 'time' => {code => 'daily', modifier => 3}, 
						} 
					],
	'PR6790' => [
						{drug => "DR3457", 
						 'time' => {code => 'daily', modifier => 12}, 
						}, 
						{drug => "DR3458", 
						 'time' => {code => 'daily', modifier => 3}, 
						} 
					]
);
    
my %drugs = (
	"DR3456"  => {'name' => 'Hydrocodone', 'dose' => {'unit' => 'mg', 'value' => 100}},
	"DR3457"  => {'name' => 'Hydrocodone', 'dose' => {'unit' => 'mg', 'value' => 250}},
	"DR3458"  => {'name' => 'Lisinopril', 'dose' => {'unit' => 'mg', 'value' => 5}},
	"DR3459"  => {'name' => 'Azithromycin', 'dose' => {'unit' => 'mg', 'value' => 10}},
	);
    
my $loggedin_user = undef;
my $active_patient = undef;

sub login
{
	my ($login, $pass) = @_;
	print "Login called with user ", $login, " and pass ", $pass, "\n"; 
	my $hash = sha256_hex($pass);
	my $user = $users{$hash};
	if(!defined($users{$hash}{login}) or ($login ne $users{$hash}{login}))
	{
		$loggedin_user = undef;
		return 0;
	}
	else
	{
		$loggedin_user = $user;
		return 1;
	}
}

sub logout
{
	print "logging out...\n";
	clear("True");
	$loggedin_user = undef;
	$topframe = undef;
	showlogin();
}

sub clear
{
	my ($top) = @_;
	
	$loginframe->gridForget();
	$userframe->gridForget();
	$patientframe->gridForget();
	$prescriptionframe->gridForget();
	
	if($top and defined($topframe))
	{
		print "removing topframe\n";
		$topframe->gridForget();
	}
}

sub get_scan()
{
	return "PA1234567";
}

sub scan_patient
{
	my $patnumber = get_scan();
	if(exists $patients{$patnumber})
	{
		$active_patient = $patnumber;
	}
	
}

sub addprescription
{
	print "Addprescription called.\n";
}

sub scan_drug
{
	return "PA1234567";
}

sub drug_administration
{
	print "checking for valid administration...";
	my $now = "now"; #placeholder
	my $drug = "drug"; #placeholder
	
	if(check_administration($now, $drug, $active_patient))
	{
		print " OK!\n";
	}
	else 
	{
		print " NOT OK! Please check the administration data.\n";
	}
	my $drugno = scan_drug();
}

sub check_administration() #just a stub for now..
{
	my ($date, $drug, $patient) = @_;
	#if(){ }....
	return "true";
}

sub showprescriptions
{
	clear();
	$prescriptionframe->gridColumnconfigure(0, -weight => 0);
	keys %prescriptions;
	
	my %dailytotals = ();
	
	my $i = 0;
	while(my($prescnum, $presc) = each %prescriptions)
	{	
		my $presclabel = $prescriptionframe->Label(-text => "Prescription ".$prescnum);
		$presclabel->grid(-row => $i, -column => 0,-columnspan => 2,-sticky => 'ew');
		$i = $i+1;
		foreach (@$presc)
		{
			print "prescription ", Dumper $_, "\n";
			my $drug = $drugs{$_->{drug}};
			my $dose = $drug->{dose};
			foreach($_->{time})
			{
				my $druglabel = $prescriptionframe->Label(-text => $drug->{name});
				my $drugdatalabel = $prescriptionframe->Label(-text => $dose->{value}.$dose->{unit}."\n".$_->{modifier}." ".$_->{code});
				$druglabel->grid(-row => $i, -column => 0,-sticky => 'ew');
				$drugdatalabel->grid(-row => $i, -column => 1,-sticky => 'ew');
				$i = $i+1;
				
				if (defined($dailytotals{$drug->{name}}))
				{
					$dailytotals{$drug->{name}} = $dailytotals{$drug->{name}} + $dose->{value} * $_->{modifier};
				}
				else
				{
					$dailytotals{$drug->{name}} = $dose->{value} * $_->{modifier};
				}
			}
		}
	}
	
	my $dailylabel = $prescriptionframe->Label(-text => "Daily Totals:");
	$dailylabel->grid(-row => $i, -column => 0,-columnspan => 2,-sticky => 'ew');
	$i = $i+1;
	while(my($drugname, $amount) = each %dailytotals)
	{
		my $druglabel = $prescriptionframe->Label(-text => $drugname);
		my $drugdatalabel = $prescriptionframe->Label(-text => $amount);
		$druglabel->grid(-row => $i, -column => 0,-sticky => 'ew');
		$drugdatalabel->grid(-row => $i, -column => 1,-sticky => 'ew');
		$i = $i+1;
	}
	
	$prescriptionframe->grid(-row => 2, -column => 0,-columnspan => 2,-sticky => 'ew');
	
	my $backbutton = $prescriptionframe->Button(-text => "Back to Main", -borderwidth => 0, -command => \&showmain);
	$backbutton->grid(-row => $i+1, -column => 0,-columnspan => 2, -pady => 20, -padx => 20,-sticky => 'ew');
}

sub showpatient
{
	clear(); #dont clear topframe
	
	my $pat_record = $patients{$active_patient};
	my $patname = $pat_record->{name};
	my $patdob = $pat_record->{dob};
	my $patdiag = $pat_record->{diagnosis};
	my $patnotes = $pat_record->{notes};
	my $patprescriptions = $pat_record->{prescriptions};
	
	
	#print 'Showing patient record ', $active_patient, $patname, $patdob, $patdiag, $patnotes;
	my $recordlabel = $patientframe->Label(-text => "Patient Record:");
    my $recordentry = $patientframe->Entry(-textvariable => \$active_patient,-state => "readonly"  );
    
    my $namelabel = $patientframe->Label(-text => "Name:");
	my $nameentry = $patientframe->LabEntry(-textvariable => \$patname,);
	
	my $doblabel = $patientframe->Label(-text => "Date of Birth:");
	my $dobentry = $patientframe->Entry(-textvariable => \$patdob, );
	
	my $diaglabel = $patientframe->Label(-text => "Diagnosis:");
	my $diagentry = $patientframe->Entry(-textvariable => \$patdiag, );
	
	my $noteslabel = $patientframe->Label(-text => "Notes:");
	my $notesentry = $patientframe->Scrolled("Text", -height => 5, -width=>15, -scrollbars => "osoe");
	$notesentry->insert('end', $patnotes);
	
	$patientframe->gridColumnconfigure(0, -weight => 0);

	$recordlabel->grid(-row => 1, -column => 0,-sticky => 'nsew');
	$recordentry->grid(-row => 1, -column => 1,-sticky => 'nsew');
	$namelabel->grid(-row => 2, -column => 0,-sticky => 'nsew');
	$nameentry->grid(-row => 2, -column => 1,-sticky => 'nsew');
	$doblabel->grid(-row => 3, -column => 0,-sticky => 'nsew');
	$dobentry->grid(-row => 3, -column => 1,-sticky => 'nsew');
	$diaglabel->grid(-row => 4, -column => 0,-sticky => 'nsew');
	$diagentry->grid(-row => 4, -column => 1,-sticky => 'nsew');
	$noteslabel->grid(-row => 5, -column => 0,-sticky => 'nsew');
	$notesentry->grid(-row => 5, -column => 1,-sticky => 'nsew');
	
	$patientframe->grid(-row => 2, -column => 0,-columnspan => 2,-sticky => 'ew');
	
	my $prescriptionlabel = $patientframe->Label(-text => "Prescriptions:");
	$prescriptionlabel->grid(-row => 6, -column => 0,-columnspan => 2, -sticky => 'ew');
	
	my $i = 7;
	foreach (@$patprescriptions)
	{
		my $pres = $prescriptions{$_};
		print "prescription ", $_, "\n";
        foreach (@$pres)
        {
			my $drug = $drugs{$_->{drug}};
			my $dose = $drug->{dose};
			#print "Drug ", $drug->{name}," ", $dose->{value}, " ", $dose->{unit} , "\n";
			foreach($_->{time})
			{
				#print "code", $_->{code}, "\n";
				#print "modifier", $_->{modifier}, "\n";
				my $druglabel = $patientframe->Label(-text => $drug->{name});
				my $drugdatalabel = $patientframe->Label(-text => $dose->{value}.$dose->{unit}."\n".$_->{modifier}." ".$_->{code});
				$druglabel->grid(-row => $i, -column => 0,-sticky => 'ew');
				$drugdatalabel->grid(-row => $i, -column => 1,-sticky => 'ew');
				$i = $i+1;
			}
		}
	}
	my $fun = $loggedin_user->{function};
	if($fun eq 'physician')
	{
		my $prescribebutton = $patientframe->Button(-text => "Prescribe", -borderwidth => 0, -command => \&addprescription);
		$prescribebutton->grid(-row => $i, -column => 0,-columnspan => 2, -pady => 20, -padx => 20,-sticky => 'ew');
	}
	elsif($fun eq 'nurse')
	{
		my $prescribebutton = $patientframe->Button(-text => "Administer Drug", -borderwidth => 0, -command => \&drug_administration);
		$prescribebutton->grid(-row => $i, -column => 0,-columnspan => 2, -pady => 20, -padx => 20,-sticky => 'ew');
		
		$nameentry -> configure(-state => "readonly" );
		$dobentry -> configure(-state => "readonly" );
		$diagentry -> configure(-state => "readonly" );
	}
	
	
	my $backbutton = $patientframe->Button(-text => "Back to Main", -borderwidth => 0, -command => \&showmain);
	$backbutton->grid(-row => $i+1, -column => 0,-columnspan => 2, -pady => 20, -padx => 20,-sticky => 'ew');
}

sub showlogin
{
	clear("true"); #will also remove topframe
           
	my $credentialslabel = $loginframe->Label(-text => "Please provide your credentials");
	my $errorlabel = $loginframe->Label(-text => "");
    
    #Text entry widget  
    my $loginlabel = $loginframe->Label(-text => "Login:");
    my $logintext = '';
    my $loginentry = $loginframe->LabEntry(-textvariable => \$logintext);
           
     #Text entry widget  
    my $passwdlabel = $loginframe->Label(-text => "Password:");
	my $passwdtext = '';
	my $passwdentry = $loginframe->LabEntry(-textvariable => \$passwdtext, -show => '*');
           
	my $button = $loginframe->Button(-text => "Login",
	-command => sub 
	{
		if(login($logintext, $passwdtext))
		{
			$errorlabel->configure(-text => "",); showmain();
		} else 
		{
			$errorlabel->configure(-text => "Credentials invalid", -foreground => 'red')
		}
	},
	);
	
	$credentialslabel->grid(-row => 0, -column => 0,-pady => 20, -padx => 20, -columnspan => 2,-sticky => "n");
	$loginentry->grid(-row => 1, -column => 1,);
	$loginlabel->grid(-row => 1, -column => 0,);
	$passwdentry->grid(-row => 2, -column => 1,);
	$passwdlabel->grid(-row => 2, -column => 0,);
	$button->grid(-row => 3, -column => 0, -columnspan => 2, -pady => 10);
	$errorlabel->grid(-row => 5, -column => 0, -columnspan => 2, -pady => 20);
	
	$loginframe->gridColumnconfigure(0, -weight => 1);
	$loginframe->grid(-row => 0, -column => 0,);
}

sub showmain
{
	clear();
	
	print Dumper $loggedin_user;
	
	my $choose_message = 'Choose an action:';
	if(defined($loggedin_user))
	{
		my $scanbutton;
		my $fun = $loggedin_user->{function};
		if($fun eq 'physician')
		{
			$scanbutton = $userframe->Button(-text => "Scan Patient", -borderwidth => 0, 
			-command => sub {
				scan_patient(); 
				showpatient();	
				});
				
		}
		elsif($fun eq 'nurse')
		{
			$scanbutton = $userframe->Button(-text => "Scan Patient", -borderwidth => 0, 
			-command => sub {
				scan_patient(); 
				showpatient();	
				});
			
		}
		elsif($fun eq 'pharmacist')
		{
			$scanbutton = $userframe->Button(-text => "Show prescriptions", -borderwidth => 0, 
			-command => sub {
				showprescriptions();	
				});
		}	
		
		gettopframe($mainframe);
		
		my $clock = $userframe->StrfClock();
		my $chooselabel = $userframe->Label(-text => $choose_message);
		
		
		$userframe->gridColumnconfigure(0, -weight => 1);
		
		
		$chooselabel->grid(-row => 1, -column => 0, -padx => 30, -pady => 10,-sticky => 'w');
		$userframe->grid("x");
		$scanbutton->grid(-row => 2, -column => 0,-columnspan => 2, -pady => 20, -padx => 20,-sticky => 'ew');
		$clock->grid(-row => 3, -column => 1,-sticky => 'se');
		
		$topframe->grid(-row => 0, -column => 0,-columnspan => 2,-sticky => 'ew');
		$userframe->grid(-row => 1, -column => 0,-columnspan => 2,-sticky => 'ew');
	}
}

sub gettopframe
{
	if(not defined($topframe))
	{
		$topframe = $mainframe->Frame();
		my $welcome_message = "";
				
		my $fun = $loggedin_user->{function};
		if($fun eq 'physician')
		{
			$welcome_message = "Welcome Doctor " . $loggedin_user->{name} . "!"
		}
		elsif($fun eq 'nurse')
		{
			$welcome_message = "Welcome Nurse " . $loggedin_user->{name} . "!"
		}
		elsif($fun eq 'pharmacist')
		{
			$welcome_message = "Welcome Pharmacist " . $loggedin_user->{name} . "!"
		}	
	
	my ($parent) = @_;
	$topframe = $parent->Frame(-borderwidth => 2, -relief => 'groove');

	my $welcomelabel = $topframe->Label(-text => $welcome_message);
	my $logoutbutton = $topframe->Button(-text => "Logout", -borderwidth => 0, -command => \&logout);

	$topframe->gridColumnconfigure(0, -weight => 1);
	$welcomelabel->grid(-row => 1, -column => 0,-pady => 2,-padx => 5,-sticky => 'nw');
	$logoutbutton->grid(-row => 1, -column => 1,-sticky => 'ne');
	}
	return $topframe;
}

showlogin();
MainLoop();


