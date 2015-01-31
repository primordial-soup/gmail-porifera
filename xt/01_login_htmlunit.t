use Test::Most;
use strict;

use YAML::XS qw/LoadFile/;
use File::HomeDir;
use Path::Class;
use WWW::HtmlUnit::Sweet show_errors => 1;

use constant GMAIL_URL => 'https://mail.google.com/mail/';
use constant GMAIL_FILTERS => 'https://mail.google.com/mail/u/0/#settings/filters';

my $config = LoadFile file(File::HomeDir->my_home, '.gmail-porifera');

my $agent = WWW::HtmlUnit::Sweet->new();
my $page = $agent->getPage( GMAIL_URL );

my $login_form = $agent->getForms()->[0];
$login_form->getInputByName('Email')->type( $config->{user} );
$login_form->getInputByName('Passwd')->type( $config->{password} );
$login_form->getInputByName('signIn')->click();

$agent->getPage( GMAIL_FILTERS );

$agent->getByXPath(  q|//span[@selector="all"]| )->click();
$agent->getByXPath(  q|//button[text()="Export"]| )->click();

