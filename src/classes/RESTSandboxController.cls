public with sharing class RESTSandboxController {		
	public string apiResponse {get; set;}
	
	public RESTSandboxController(){
		
	}
	
	private DSCredentials m_credentials = null;
	public DSCredentials Credentials{
		get{
			if(m_credentials == null){
				m_credentials = new DSCredentials();
				m_credentials.Username = 'username';
				m_credentials.Password = 'password';
				m_credentials.IntegratorKey = 'key';
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
		
		//HOWTO: Parse a particular field out of the JSON response
		//string templateId = this.parseField(apiResponse, 'templateId');
		
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
}