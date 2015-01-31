use Test::Most;
use strict;

use YAML::XS qw/LoadFile/;
use File::HomeDir;
use Path::Class;
use WWW::Mechanize::Firefox;
use Cwd;

use constant GMAIL_URL => 'https://mail.google.com/mail/';
use constant GMAIL_BASIC_HTML_URL => 'https://mail.google.com/mail/u/0/?ui=html';

use constant GMAIL_FILTERS => 'https://mail.google.com/mail/u/0/#settings/filters';

my $config = LoadFile file(File::HomeDir->my_home, '.gmail-porifera');
my $mech = WWW::Mechanize::Firefox->new();
$mech->get(GMAIL_URL);

$mech->submit_form( with_fields => {
	Email => $config->{user},
	Passwd => $config->{password},
});
$mech->get(GMAIL_FILTERS);

my $ff = $mech->application();
my $prefs = $ff->repl->expr(<<'JS');
  Components.classes["@mozilla.org/preferences-service;1"]
    .getService(Components.interfaces.nsIPrefBranch);
JS

# From <http://stackoverflow.com/questions/1176348/access-to-file-download-dialog-in-firefox>
$prefs->setIntPref("browser.download.folderList",2);
#$prefs->setBoolPref("browser.download.manager.showWhenStarting",False)
#fp.set_preference("browser.download.dir",getcwd())
$prefs->setCharPref("browser.helperApps.neverAsk.openFile","text/csv,application/force-download");
$prefs->setCharPref("browser.helperApps.neverAsk.saveToDisk","text/csv,application/force-download");

$mech->xpath( q|//span[@selector="all"]| , one => 1 )->click;
$mech->xpath( q|//button[text()="Export"]| , one => 1 )->click;

$prefs->resetUserPrefs();

# For later: look at
# - <http://www.mozdev.org/source/browse/downloadstatusbar/>
# - <http://blog.techno-barje.fr//post/2009/11/02/Catch-all-requests-to-a-specific-mime-type-file-extension-in-Firefox/>
# - <http://stackoverflow.com/questions/9032760/how-to-change-the-download-folder-destenation-in-firefox>
# - <https://developer.mozilla.org/en-US/docs/Document_Loading_-_From_Load_Start_to_Finding_a_Handler>
# - <https://code.google.com/p/selenium/source/browse/javascript/firefox-driver/js/promptService.js>
# - <https://metacpan.org/pod/WWW::Mechanize::Firefox#SEE-ALSO>
# - <https://developer.mozilla.org/en-US/Add-ons/SDK/Tutorials/Creating_event_targets>
# - <https://developer.mozilla.org/en-US/docs/Mozilla/JavaScript_code_modules/Downloads.jsm#Observing_downloads>
# - <https://github.com/Infocatcher/Close_Download_Tabs/blob/master/bootstrap.js> nsIWebProgressListener
# - <http://stackoverflow.com/questions/596900/problems-with-using-nsiuricontentlistener-in-firefox-extension>
# - <https://github.com/zotero/zotero/blob/master/chrome/content/zotero/downloadOverlay.js>
# - <https://developer.mozilla.org/en-US/Add-ons/Overlay_Extensions/XUL_School/Intercepting_Page_Loads>

done_testing;
