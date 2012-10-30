public class DSLoginInformation {
	public string accountId;
	public string baseUrl;
	public string email;
	public string isDefault;
	public string name;
	public string siteDescription;
	public string userId;
	public string userName;
	
	public static DSLoginInformation deserialize(HttpResponse httpResponse){
		try{
			LoginInformationResult result = (LoginInformationResult) JSON.deserialize(httpResponse.getBody(), 
										LoginInformationResult.class);
			for(DSLoginInformation loginInfo : result.loginAccounts){
				if(loginInfo.isDefault.toLowerCase() == 'true'){
					return loginInfo;
				}
			}
		}
		catch(System.JSONException ex){
			System.debug('JSON Parsing error deserializing Login Information: ' + ex.getMessage());
			return null;
		}
		
		return null;
	}
	
	private class LoginInformationResult{
		public string apiPassword;
		public List<DSLoginInformation> loginAccounts;
	}
	
	private static testMethod void basicGetSetTests(){
		DSLoginInformation info = new DSLoginInformation();
		info.accountId 	= 'foo';
		info.baseUrl 	= 'foo';
		info.email 		= 'foo';
		info.isDefault 	= 'foo';
		info.name 		= 'foo';
		info.siteDescription = 'foo';
		info.userId 	= 'foo';
		info.userName 	= 'foo';
		System.assertEquals('foo', info.accountId);
		System.assertEquals('foo', info.baseUrl);
		System.assertEquals('foo', info.email);
		System.assertEquals('foo', info.isDefault);
		System.assertEquals('foo', info.name);
		System.assertEquals('foo', info.siteDescription);
		System.assertEquals('foo', info.userId);
		System.assertEquals('foo', info.userName);
		
		LoginInformationResult response = new LoginInformationResult();
		response.apiPassword = 'foo';
		System.assertEquals('foo', response.apiPassword);
		response.loginAccounts = new List<DSLoginInformation>();
		response.loginAccounts.add(info);
		System.assertEquals(1, response.loginAccounts.size());
	}
	
	private static testMethod void deserializationTests(){
		HttpResponse testResponse = new HttpResponse();
		DSLoginInformation nullLoginInfo = (DSLoginInformation)DSLoginInformation.deserialize(testResponse);
		System.assertEquals(null, nullLoginInfo);
		
		testResponse.setBody(TEST_DATA);
		LoginInformationResult loginResponse = (LoginInformationResult) JSON.deserialize(testResponse.getBody(), 
									LoginInformationResult.class);
		System.assertNotEquals(null, loginResponse);
		System.assertEquals('super-secret-password', loginResponse.apiPassword);
		System.assertNotEquals(null, loginResponse.loginAccounts);
		System.assertEquals(2, loginResponse.loginAccounts.size());
		System.assertEquals('654321', loginResponse.loginAccounts[0].accountId);
		System.assertEquals('12345678-82a2-4d6c-891c-f2f667654321', loginResponse.loginAccounts[0].userId);
		
		System.assertEquals('123456', loginResponse.loginAccounts[1].accountId);
		System.assertEquals('12345678-82a2-4d6c-891c-f2f661234567', loginResponse.loginAccounts[1].userId);
		
		DSLoginInformation loginInfo = (DSLoginInformation)DSLoginInformation.deserialize(testResponse);
		System.assertEquals('123456', loginInfo.accountId);
		System.assertEquals('https://demo.docusign.net/restapi/v2/accounts/123456', loginInfo.baseUrl);
		System.assertEquals('user@domain.com', loginInfo.email);
		System.assertEquals('true', loginInfo.isDefault);
		System.assertEquals('DocuSign', loginInfo.name);
		System.assertEquals('', loginInfo.siteDescription);
		System.assertEquals('12345678-82a2-4d6c-891c-f2f661234567', loginInfo.userId);
		System.assertEquals('First Last', loginInfo.userName);
		//LoginInformationResult r = (LoginInformationResult)DSLoginInformation.deserialize(testResponse);
	}
	
	private static string TEST_DATA = '{' + 
	  '"apiPassword": "super-secret-password",' +
	  '"loginAccounts": [' +
	    '{' +
	      '"accountId": "654321",' +
	      '"baseUrl": "https://demo.docusign.net/restapi/v2/accounts/654321",' +
	      '"email": "user@domain.com",' +
	      '"isDefault": "false",' +
	      '"name": "DocuSign",' +
	      '"siteDescription": "",' +
	      '"userId": "12345678-82a2-4d6c-891c-f2f667654321",' +
	      '"userName": "First Last"' +
	    '},' +
	    '{' +
	      '"accountId": "123456",' +
	      '"baseUrl": "https://demo.docusign.net/restapi/v2/accounts/123456",' +
	      '"email": "user@domain.com",' +
	      '"isDefault": "true",' +
	      '"name": "DocuSign",' +
	      '"siteDescription": "",' +
	      '"userId": "12345678-82a2-4d6c-891c-f2f661234567",' +
	      '"userName": "First Last"' +
	    '}' +
	  ']' +
	'}';
}