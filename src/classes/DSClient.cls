public with sharing class DSClient {
	private final DocuSignConfiguration config;
	//TODO: Require as input from Developer. Only used by managed package calls
	//move to configuration custom object
	private string integratorKey 	= 'DOCU-339fa93c-fcf0-4390-8141-2e0f071ffa2a';	
	public string testResponseData {get; set;}
	// public final DSLoginInformation loginInformation;
    
	public DSClient(){
		config 	= new DocuSignConfiguration();		
		config.OrganizationId = UserInfo.getOrganizationId();
		config.initConfiguration();
		
		testResponseData = 'Not set;';
	}
	
	private string BaseURL{
		get{ return config.DocuSignBaseURL; }
	}
	
	private integer m_apiVersion = 2;
	public integer APIVersion{
		get{ return m_apiVersion; }
		set{ m_apiVersion = value;}
	}
	
	public string BaseEndpointURL{
		get{ return this.BaseURL + 'restapi/' + 'v' + this.APIVersion + '/'; }
	}
		
	public string AccountId{
		get{ return config.DocuSignAccountId;}
	}
	
	private integer m_timeout = 59000; //59 seconds
	public integer Timeout{
		get{ return m_timeout;}
		set{ m_timeout = value; }
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

    private HttpResponse DocuSignRestAPIReturnResponse(string endpointURL, string HTTPOperation, string reqBody) {
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		if (reqBody != null)
		{
			req.setBody(reqBody);
		}
		
		req.setEndpoint(endpointURL);
		req.setMethod(HTTPOperation);
		req.setHeader('Content-Type', 'application/json');
		req.setHeader('Accept', 'application/json');
		req.setHeader('X-DocuSign-Authentication', GetDocuSignCredentialsXml() );
		req.setTimeout(Timeout);
		HttpResponse res = null;
		try{
			if(Test.isRunningTest()){
				res = new HttpResponse();
				if (testResponseData != null && testResponseData.length() > 0)
				{
					res.setBody(testResponseData);
				}
			} else {
				res = h.send(req);
			}
			system.debug('request = ' + req.getEndPoint());
			system.debug('request.getBody() = ' + req.getBody());
			system.debug('response.getBody() = ' + res.getBody());
		}
		catch(Exception excp)
		{
			res = new HttpResponse();
			res.setBody('ERROR: ' + excp.getMessage());
			system.debug('PostToDocuSignAPIReturnResponse error: ' + excp);
		}
		return res;
	}
	
	private string GetDocuSignCredentialsXml()
    {
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartElement(null,'DocuSignCredentials',null);
            w.writeStartElement(null,'Username',null);
                w.writeCharacters(config.DocuSignUserName);
            w.writeEndElement();    
            w.writeStartElement(null,'Password',null);
                w.writeCharacters(config.DocuSignPassword);
            w.writeEndElement();
            w.writeStartElement(null,'IntegratorKey',null);
                w.writeCharacters(this.integratorKey);
            w.writeEndElement();
            if (config.UseSendOnBehalfOf)
            {
				string sendOnBehalfOfId = config.SendOnBehalfOfID;
                if (config.SendOnBehalfOfID == null || config.SendOnBehalfOfID.length() == 0)
                {
					sendOnBehalfOfId = 'NOT_CONFIGURED';
                }
				w.writeStartElement(null,'SendOnBehalfOf',null);
                    w.writeCharacters(sendOnBehalfOfId);
				w.writeEndElement();
			}
		w.writeEndElement();
		string xml = w.getXmlString();
		w.close();
		return xml;
	}
	
	public static testMethod void testXMLCredentials(){
		DSClient client = new DSClient();
		string xml = client.GetDocuSignCredentialsXml();
		System.assertNotEquals(null, xml);
	}
	
	public static testMethod void testRESTGet(){
		DSClient client = new DSClient();
		
		client.testResponseData = '{"agents":[],"carbonCopies":[],"certifiedDeliveries":[],"editors":[],"inPersonSigners":[{"note":"","recipientId":"1","requireIdLookup":"false","roleName":"Signer 1","routingOrder":"1","status":"sent","hostEmail":"john.doe@docusign.com","hostName":"John Doe","signerName":"Fred Flintstone"}],"intermediaries":[],"recipientCount":"2","signers":[{"note":"","recipientId":"2","requireIdLookup":"false","roleName":"Signer 2","routingOrder":"1","status":"sent","email":"jane.doe@gmail.com","name":"Jane Doe"}]}';
		HttpResponse httpResponse = client.Get( client.BaseEndpointURL + 'accounts/someAccountID/envelopes/someEnvelopeID/recipients');
		
		DSRESTAPI.Response restResponse = DSRESTAPI.Deserialize(httpResponse, DSRESTAPI.RecipientStatusResponse.class);
		system.assert(restResponse.status);
		DSRESTAPI.RecipientStatusResponse recipResponse = (DSRESTAPI.RecipientStatusResponse) restResponse.deserializedObject;
		system.assertEquals(1, recipResponse.signers.size());
		system.assertEquals(1, recipResponse.inPersonSigners.size());
	}
	
	public static testMethod void testRESTPost(){
		DSClient client = new DSClient();
		
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