#!/usr/bin/python
from selenium import webdriver
import yaml

config_file = open('/home/zaki/.gmail-porifera', 'r')
config = yaml.load(  config_file )

GMAIL_URL = 'https://mail.google.com/mail/'
GMAIL_FILTERS = 'https://mail.google.com/mail/u/0/#settings/filters'

driver = webdriver.PhantomJS() # or add to your PATH

driver.set_window_size(1024, 768) # optional

driver.get(GMAIL_URL)

email = driver.find_element_by_id('Email')
pw = driver.find_element_by_id('Passwd')

email.send_keys( config['user'] )
pw.send_keys( config['password'])
pw.submit()

driver.get(GMAIL_FILTERS)
driver.command_executor._commands['executePhantomScript'] = ('POST', '/session/$sessionId/phantom/execute')

driver.execute('executePhantomScript', {'script': '''
    document.requests = [];
    var page = this; // won't work otherwise
    page.onResourceRequested = function(requestData, request) {
      document.requests.push( requestData )
      console.log( request );
      console.log( JSON.stringify(requestData) );
    }
    page.onResourceReceived = function(requestData, request) {
      console.log( request );
      console.log( JSON.stringify(requestData) );
    };
    page.onFilePicker = function(oldFile) {
       console.log('onFilePicker(' + oldFile + ') called');
       return 'mailFilters.xml';
    };
''', 'args': []})


driver.find_element_by_xpath( '//span[@selector="all"]' ).click()

button = driver.find_element_by_xpath( '//button[text()="Export"]' )

button.click()

driver.save_screenshot('screen.png') # save a screenshot to disk
