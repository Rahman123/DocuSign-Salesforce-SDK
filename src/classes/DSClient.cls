/*
 * DSClient.cls
 * Main class for interfacing with DocuSign web services.
 * Provides an abstraction layer to the DocuSign REST API.
 */
public with sharing class DSClient {
	public integer Timeout     	{ get; set;}
	public string EndpointURL  	{ get; set;}
	public string RequestBody  	{ get; set;}
	public string ResponseBody 	{ get; set;}
	public List<string> Errors 	= new List<string>();
	public string TestResponseData {get; set;}
    
	public DSClient(DSCredentials credentials){		
		m_credentials = credentials;
		validateCredentials();
		Timeout = 59000;
		TestResponseData = 'Not set';
	}
	
	private void validateCredentials(){
		if(this.m_credentials == null){
			this.Errors.add('Credential object passed to DSClient constructor cannot be null.');
		}
		if(	m_credentials.BaseURL == null ||
			m_credentials.BaseURL == '' ||
			m_credentials.BaseURL.startsWith('https') == false){
				this.Errors.add('DSCredential.BaseURL is invalid.');
		}
		if( m_credentials.BaseURL.endsWith('/') == false){
			m_credentials.BaseURL += '/';
		}
		if(	m_credentials.Username == null ||
			m_credentials.Username == ''){
				this.Errors.add('DSCredential.Username is invalid.');
		}
		if(	m_credentials.Password == null ||
			m_credentials.Password == ''){
				this.Errors.add('DSCredential.Password is invalid.');
		}
		if(	m_credentials.IntegratorKey == null ||
			m_credentials.IntegratorKey == ''){
				this.Errors.add('DSCredential.IntegratorKey is invalid.');
		}
		if(HasError){
			string message;
			for(string error : Errors){
				message += error + '------';
			}
			throw new DSException(message);
		}
	}
	
	public boolean HasError{
		get{ return this.Errors.size() > 0; }
	}
	
	private final DSCredentials m_credentials;
	public DSCredentials Credentials{
		get{ return this.m_credentials; }
	}
	
	private string m_baseURL = null;
	public string BaseURL{
		get{  
			if(this.m_baseURL == null){
				this.m_baseURL = Credentials.BaseURL;
			}
			return this.m_baseURL;
		}
		set{ m_baseURL = value; }
	}
	
	private integer m_apiVersion = 2;
	public integer APIVersion{
		get{ return m_apiVersion; }
		set{ m_apiVersion = value;}
	}
	
	public string BaseEndpointURL{
		get{ return this.BaseURL + 'restapi/' + 'v' + this.APIVersion + '/'; }
	}
	
	private DSLoginInformation m_loginInfo = null;
	public DSLoginInformation LoginInfo{
		get{
			if(this.m_loginInfo == null){
				HttpResponse response = this.Get(BaseEndpointURL + '/login_information');
				if(response.getStatusCode() == 401){
					throw new DSException('USER_AUTHENTICATION_FAILED: One or both of Username and Password are invalid.');
				}
				else if(response.getStatusCode() != 200){
					throw new DSException('USER_AUTHENTICATION_FAILED:' + response.getBody());
				}
				
				this.m_loginInfo = DSLoginInformation.deserialize(response);
				if(this.m_loginInfo.hasError){
					throw new DSException('Login failed: ' +  m_loginInfo.errorMessage);
				}
			}
			return m_loginInfo;
		}
	}
	
	private string m_accountId = null;
	public string AccountId{
		get{
			if(m_accountId == null){
				this.m_accountId = this.LoginInfo.accountId;
			}
			return this.m_accountId;
		}
		set { m_accountId = value; }
	}
	
	public List<DSTemplate> getTemplates(){		
		HttpResponse httpResponse = Get(BaseEndpointURL + '/accounts/' + AccountId + '/templates');
		return DSTemplate.deserialize(httpResponse);
	}
	
	public DSSignatureResult requestSignature(DSSignatureRequest request){
		
		DSSignatureResult result = new DSSignatureResult();
		return result;	
	}
	
	public HttpResponse Get(string restURL){
		return DocuSignRestAPIReturnResponse(restURL, 'GET', null);
	}

	public HttpResponse Post(string restURL, string reqBody){
		return DocuSignRestAPIReturnResponse( restURL,                                              
                                              'POST',
                                              reqBody == null ? '' : reqBody);
	}

    private HttpResponse DocuSignRestAPIReturnResponse(string restURL, string HTTPOperation, string reqBody) {
    	
		Http http = new Http();
		HttpRequest request = new HttpRequest();
		if (reqBody != null)
		{
			request.setBody(reqBody);
			this.RequestBody = reqBody;
		}	
		this.EndpointURL = restURL;
		
		request.setEndpoint(restURL);
		request.setMethod(HTTPOperation);
		request.setHeader('Content-Type', 'application/json');
		request.setHeader('Accept', 'application/json');
		request.setHeader('X-DocuSign-Authentication', this.Credentials.toXML() );
		request.setTimeout(Timeout);
		
		HttpResponse response = null;
		try{
			if(Test.isRunningTest()){
				response = new HttpResponse();
				if (testResponseData != null && testResponseData.length() > 0)
				{
					response.setBody(testResponseData);
				}
			} else {
				response = http.send(request);
			}
			system.debug('request = ' + request.getEndPoint());
			system.debug('request.getBody() = ' + request.getBody());
			system.debug('response.getBody() = ' + response.getBody());
						
			this.ResponseBody = response.getBody();
		}
		catch(Exception excp)
		{
			response = new HttpResponse();
			response.setBody('ERROR: ' + excp.getMessage());
			system.debug('PostToDocuSignAPIReturnResponse error: ' + excp);
		}
		return response;
	}
	
	public static testMethod void testRESTGet(){
		DSCredentials credentials = new DSCredentials();
		credentials.BaseURL			= 'https://demo.docusign.net/';
		credentials.Username		= 'username';
		credentials.Password		= 'password';
		credentials.IntegratorKey	= 'key';
		
		DSClient client = new DSClient(credentials);
		client.testResponseData = '{"agents":[],"carbonCopies":[],"certifiedDeliveries":[],"editors":[],"inPersonSigners":[{"note":"","recipientId":"1","requireIdLookup":"false","roleName":"Signer 1","routingOrder":"1","status":"sent","hostEmail":"john.doe@docusign.com","hostName":"John Doe","signerName":"Fred Flintstone"}],"intermediaries":[],"recipientCount":"2","signers":[{"note":"","recipientId":"2","requireIdLookup":"false","roleName":"Signer 2","routingOrder":"1","status":"sent","email":"jane.doe@gmail.com","name":"Jane Doe"}]}';
		HttpResponse httpResponse = client.Get( client.BaseEndpointURL + 'accounts/someAccountID/envelopes/someEnvelopeID/recipients');
		
		DSRESTAPI.Response restResponse = DSRESTAPI.Deserialize(httpResponse, DSRESTAPI.RecipientStatusResponse.class);
		system.assert(restResponse.status);
		DSRESTAPI.RecipientStatusResponse recipResponse = (DSRESTAPI.RecipientStatusResponse) restResponse.deserializedObject;
		system.assertEquals(1, recipResponse.signers.size());
		system.assertEquals(1, recipResponse.inPersonSigners.size());
	}
	
	public static testMethod void testRESTPost(){
		DSCredentials credentials = new DSCredentials();
		credentials.Username		= 'username';
		credentials.Password		= 'password';
		credentials.IntegratorKey	= 'key';
		
		DSClient client = new DSClient(credentials);
		
		string reqBody = '{"authenticationMethod":"email","returnUrl":"https://dsfs.na7.visual.force.com/apex/dsfs__docusign_signnowdone?DSEID=dseid&envelopeId=envId&event=Sent&signNow=1&SourceID=sourceid","recipientId":"1","email":"jane.doe@gmail.com","userName":Jane Doe"}';
        client.testResponseData = '{"url":"https://test1.docusign.net/Member/StartInSession.aspx?t=fc1c34c2-23ac-44e0-b41c-136f3468b75d"}';
		HttpResponse httpResponse = client.Post(
												client.BaseEndpointURL + 'accounts/someAccountID/envelopes/someEnvelopeID/views/recipient.json',
												reqBody);
		DSRESTAPI.Response restResponse = DSRESTAPI.Deserialize(httpResponse, DSRESTAPI.RequestTokenResponse.class);
		system.assert(restResponse.status);
		DSRESTAPI.RequestTokenResponse rrtResponse = (DSRESTAPI.RequestTokenResponse) restResponse.deserializedObject;
		system.assertEquals('https://test1.docusign.net/Member/StartInSession.aspx?t=fc1c34c2-23ac-44e0-b41c-136f3468b75d', rrtResponse.url);
		DocuSignUnitTestSettings.PerformingUnitTests = false;
	}
}