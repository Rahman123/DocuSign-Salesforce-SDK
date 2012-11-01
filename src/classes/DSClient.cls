/*
 * DSClient.cls
 * Main class for interfacing with DocuSign web services.
 * Provides an abstraction layer to the DocuSign REST API.
 */
global with sharing class DSClient {
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
		HttpResponse httpResponse = Post(BaseEndpointURL + '/accounts/' + AccountId + '/envelopes', request.serialize());
		return DSSignatureResult.deserialize(httpResponse);
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
}