public with sharing class DSSignatureRequest {
	public boolean fromTemplate = false;
	public boolean fromDocument = false;
	public string accountId;
	public string emailSubject;
	public string emailBlurb;
	public string templateId;
	public List<DSCustomField> customFields;
	public List<DSTemplateRole> templateRoles;
	
	public static testMethod void persistenceTests(){
		DSSignatureRequest request = new DSSignatureRequest();
		request.fromTemplate = true;
		request.accountId = 'foo';
		request.emailBlurb = 'foo';
		request.emailSubject = 'foo';
		request.templateId = 'foo';
		request.customFields = new List<DSCustomField>();
		request.templateRoles = new List<DSTemplateRole>();
		
		System.assertEquals(true, request.fromTemplate);
		System.assertEquals(false, request.fromDocument);
		System.assertEquals('foo', request.accountId);
		System.assertEquals('foo', request.emailBlurb);
		System.assertEquals('foo', request.emailSubject);
		System.assertEquals(0, request.customFields.size());
		System.assertEquals(0, request.templateRoles.size());
	}
	
	public static string TEST_DATA = '{' +
			  '"emailSubject": "test email subject",' +
			  '"emailBlurb": "test email blurb",' +
			  '"customFields": {' +
			    '"textCustomFields": [' +
			      '{' +
			        '"name": "customName",' +
			        '"show": "true",' +
			        '"required": "false",' +
			        '"value": "customValue"' +
			      '}' +
			    ']' +
			  '},' +
			  '"templateId": "c214c9e7-c737-4b50-aa01-fe4d7f0e2434",' +
			  '"templateRoles": [' +
			    '{' +
			      '"email": "c-mike.leach@docusign.com",' +
			      '"name": "Mike Leach",' +
			      '"roleName": "Signer"' +
			    '}' +
			  '],' +
			  '"status": "sent"' +
		'}';
}