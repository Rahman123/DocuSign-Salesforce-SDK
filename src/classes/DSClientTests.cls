@IsTest
public with sharing class DSClientTests {

	public static testMethod void requestSignatureTests(){
		//DSClient client = new DSClient();
	}
	/*
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
	*/
}