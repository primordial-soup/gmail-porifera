use Test::Most;
use strict;

use YAML::XS qw/LoadFile/;
use File::HomeDir;
use Path::Class;
use WWW::Mechanize::PhantomJS;

use constant GMAIL_URL => 'https://mail.google.com/mail/';
use constant GMAIL_BASIC_HTML_URL => 'https://mail.google.com/mail/u/0/?ui=html';

use constant GMAIL_FILTERS => 'https://mail.google.com/mail/u/0/#settings/filters';

my $config = LoadFile file(File::HomeDir->my_home, '.gmail-porifera');
my $mech = WWW::Mechanize::PhantomJS->new();
$mech->viewport_size({ width => 1388, height => 792 });
$mech->get(GMAIL_URL);

$mech->submit_form( with_fields => {
	Email => $config->{user},
	Passwd => $config->{password},
});
$mech->get(GMAIL_FILTERS);
$mech->eval_in_page( q| document.evaluate('//span[@selector="all"]', document, null, XPathResult.ANY_UNORDERED_NODE_TYPE, null ).singleNodeValue.click(); document.evaluate('//button[text()="Export"]', document, null, XPathResult.ANY_UNORDERED_NODE_TYPE, null ).singleNodeValue.click(); |);
#$mech->click( { xpath => q|//span[@selector="all"]| })
$mech->xpath( q|//span[@selector="all"]| , one => 1 )->click
#$mech->click( { xpath => q|//button[text()="Export"]| })
$mech->xpath( q|//button[text()="Export"]| , one => 1 )->click

# file('out.html')->spew( $mech->content ); file('screen.png')->spew( $mech->content_as_png ); 1

#use HTML::Display; my $browser = HTML::Display->new(); $browser->display( html => $response->decoded_content );
#use DDP; p $response->decoded_content;
#use DDP; p $mech->content;


done_testing;
