public with sharing class DocuSignSDKHomeController {		
	public string apiResponse {get; set;}
	public string templateId {get; set;}
	public string envelopeId {get; set;}
	public boolean configured {get;set;}
	
	public DocuSignSDKHomeController(){		
		//Check if credentials are set. Show setup splash pageBlock if not.		
		configured = Credentials.areConfigured();
	}
	
	private DSCredentials m_credentials = null;
	public DSCredentials Credentials{
		get{
			if(m_credentials == null){
				m_credentials = new DSCredentials();
			}
			return m_credentials;
		}
	}
	
	private DSClient m_client = null;
	public DSClient Client{
		get{
			if(this.m_client == null){
				m_client = new DSClient(this.Credentials);
			}
			return m_client;
		}
	}
	
	public PageReference getLoginInformation(){
		HttpResponse httpResponse = Client.Get(Client.BaseEndpointURL + '/login_information');
		this.apiResponse = httpResponse.getBody();
		return null;
	}
	
	public PageReference getTemplates(){		
		this.apiResponse = '';
		List<DSTemplate> templates = Client.getTemplates();
		for(DSTemplate template : templates){
			this.apiResponse += template.templateId + '<br/>';
			this.apiResponse += template.name + '<br/>';
		}
		
		return null;
	}
	
	public PageReference getEnvelopes(){
		String lastWeek = EncodingUtil.urlEncode(DateTime.now().addDays(-7).format('MM/dd/yyyy hh:mm:ss a') , 'UTF-8');
		
		HttpResponse httpResponse = this.Client.Get(Client.BaseEndpointURL + 
									'accounts/' + Client.AccountId + '/envelopes?from_date=' + lastWeek);
		return null;
	}
	
	public PageReference requestSignatureFromTemplate(){
		this.apiResponse = '';		
		User u = [SELECT Id, Email, Name FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
		DSSignatureRequest request = new DSSignatureRequest(DSSignatureRequest.DocumentSource.TEMPLATE);
		request.emailSubject 	= 'Sandbox requestSignatureFromTemplate()';
		request.emailBlurb		= 'email body';
		request.templateId		= this.templateId;
		request.templateRoles.add( new DSTemplateRole( u.Email, u.Name, 'Signer'));
		
		DSSignatureResult result = this.Client.requestSignature(request);
		
		this.apiResponse = 'Signature request sent to ' + u.Email + '<br/>' + 
			'EnvelopeID: ' + result.envelopeId + '<br/>' +
			'Status: ' + result.status + '<br/>' + 
			'URI: '	+ result.uri + '<br/>' +
			'Timestamp: ' + result.statusDateTime;
			
		this.envelopeId = result.envelopeId;
			
		return null;
	}
	
	public PageReference serializeTemplateRequest(){
		DSSignatureRequest request = new DSSignatureRequest(DSSignatureRequest.DocumentSource.TEMPLATE);
		request.emailSubject = 'please sign';
		request.emailBlurb = 'click here';
		request.templateId = 'template id';
		
		DSCustomField f = new DSCustomField();
		f.name = 'field name';
		f.value = 'field value';
		request.customFields = new List<DSCustomField>();
		request.customFields.add(f);
		
		JSONGenerator gen = JSON.createGenerator(false);
		apiResponse = request.serialize(gen).getAsString();
		return null;
	}
	
	public PageReference serializeDocumentRequest(){
		User u = [SELECT Id, Email, Name FROM User WHERE Id=:UserInfo.getUserId() LIMIT 1];
		DSSignatureRequest request = new DSSignatureRequest(DSSignatureRequest.DocumentSource.DOCUMENT);
		request.emailSubject = 'Please Sign (SDK Test)';
		request.emailBlurb = 'This document has been merged with a custom Order template object';
		
		Order__c testOrder = [SELECT Id, Name from Order__c LIMIT 1];
		if(testOrder == null){
			throw new DSException('Create at least one Order object before testing this feature.');
		}
		DSDocument doc = new DSDocument();
		doc.name	= 'testOrder.pdf';
		doc.sobjectId = testOrder.Id;
		doc.apexPathURL = '/apex/ordertemplate';
		request.documents.add(doc);
		
		DSRecipient recipient = new DSRecipient();
		recipient.email = u.Email;
		recipient.name = u.Name;
		request.recipients.add(recipient);
		
		if(request.isValid() == false){
			apiResponse = 'There were validation errors:<br/>';
			for(string error : request.errors){
				apiResponse += error +  '<br/>';
			}
		}
		else{
			DSSignatureResult result = Client.requestSignature(request);
			this.apiResponse = 'Signature request sent to ' + request.recipients[0].email + '<br/>' + 
			'EnvelopeID: ' + result.envelopeId + '<br/>' +
			'Status: ' + result.status + '<br/>' + 
			'URI: '	+ result.uri + '<br/>' +
			'Timestamp: ' + result.statusDateTime;
		}
		return null;
	}
	
	public string parseField(string jsonString, string fieldName){		
		JSONParser parser = JSON.createParser(jsonString);
		while (parser.nextToken() != null) {
			if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
				String jsonFieldName = parser.getText();
				parser.nextToken();
				if(jsonFieldName == fieldName) {
					return parser.getText();
				}
			}
		}
		return null;
	}
	
	private static testMethod void tests(){
		DocuSignSDKHomeController controller = new DocuSignSDKHomeController();
		try{
			DSClient client = controller.Client;	
		}
		catch(DSException ex){
			
		}
	}
}