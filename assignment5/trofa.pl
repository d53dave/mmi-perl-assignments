#!/usr/bin/perl -w
use strict;
use warnings;
use Tk;
use Tk::LabFrame;
use Digest::SHA qw(sha256_hex);
use Data::Dumper;
$Data::Dumper::Indent = 1;

my %users = (
    "73475cb40a568e8da8a045ced110137e159f890ac4da883b6b17dc651b3a8049" => {'login' => 'doc1', 
																		   'name' => 'Gregory House', 
																		   'function' => 'physician'
																		   },
    "cc921e1511ff878ac7b27b188a2f263b907ed64fde556b967a4066b187608ca8" => {'login' => 'nurse1', 
																		   'name' => 'Steve Brown', 
																		   'function' => 'nurse'
																		   },
    "801eff9f8d95d49299ae8e9fb04679009011f766df325a01b37642650eff7190" => {'login' => 'pharm1', 
																			'name' => 'Alexander Flemming', 
																			'function' => 'pharmacist'
																		  }, 
    );
    
my %patients = (
    "PA1234567"  => {'name' => 'Norman Normal', 
					 'dob' => '19.11.1956', 
					 'diagnosis' => 'dead', 
					 'prescription' => [
						{'drug' => "DE3456", 
						 'time' => {'code' => 'daily', 'modifier' => 3}, 
						 'dose' => {'unit' => 'mg', 'value' => 100}
						}, 
						{'drug' => "DE3456", 
						 'time' => {'code' => 'daily', 'modifier' => 3}, 
						 'dose' => {'unit' => 'mg', 'value' => 100}
						} 
					]
					},
    "PA1234568" => {'name' => 'Steve Jobs', 'function' => 'nurse', 'diagnosis' => 'dead'},
    );
    
    
my %drugs = (
	"DR3456"  => {'name' => 'Hydrocodone'},
	"DR3457"  => {'name' => 'Lisinopril'},
	"DR3458"  => {'name' => 'Azithromycin'},);
    
my $loggedin_user = undef;

sub login
{
	my ($login, $pass) = @_;
	my $hash = sha256_hex($pass);
	my $user = $users{$hash};
	if(!defined($users{$hash}{login}) or ($login ne $users{$hash}{login}))
	{
		$loggedin_user = undef;
		return 1;
	}
	else
	{
		$loggedin_user = $user;
		return 0;
	}
}

sub scan
{
	return "PA1234567";
}

print login("doc1", "42");
print Dumper $loggedin_user;

