/*
 * DSCredentials.cls
 * Class structure for managing authentication credentials to the DocuSign REST API.
 * Optionally hard code credentials into this class or dynamically load them from
 * custom settings.
 *
 * TO CREATE DEVELOPER ACCOUNT CREDENTIALS
 * Visit http://www.docusign.com/developer-center
 */
global with sharing class DSCredentials {
	// OPTION 1: Hard code credentials here.
	// OPTION 2: Create an instance of DSCredentials and set these properties in the calling class. 
	public string BaseURL		= 'https://demo.docusign.net/';
	public string Username  	= '';
	public string Password  	= '';
	public string IntegratorKey = '';
		
	public DSCredentials(){		
		// OPTION 3: Dynamically load and set credentials here.
	}
	
	public string toXML(){
		return '<DocuSignCredentials>'+
			'<Username>' + this.Username + '</Username>'+
			'<Password>' + this.Password + '</Password>'+
			'<IntegratorKey>' + this.IntegratorKey + '</IntegratorKey>'+
			'</DocuSignCredentials>';
	}
	
	public static testMethod void persistenceTests(){
		DSCredentials credentials = new DSCredentials();
		credentials.BaseURL	 = 'https://demo.docusign.net';
		credentials.Username = 'zzz';
		credentials.Password = 'yyy';
		credentials.IntegratorKey = 'aaa';
		
		System.assertEquals('https://demo.docusign.net', credentials.BaseURL);
		System.assertEquals('zzz', credentials.Username);
		System.assertEquals('yyy', credentials.Password);
		System.assertEquals('aaa', credentials.IntegratorKey);
		System.assert(credentials.toXML().contains('zzz') && credentials.toXML().contains('yyy'));
	}
}