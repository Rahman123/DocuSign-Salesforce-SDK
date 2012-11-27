public with sharing class DSTemplateController {
	public string Message {get; set;}
	Id m_id 			= null;
	
	public DSTemplateController(){
		m_id = ApexPages.currentPage().getParameters().get('id');
		if(m_id == null){
			Message = 'Missing id parameter. View an Agreement record and click on "Preview Agreement" to see this template in action.';
		}
		else{
			Message = '';
		}
	}
	
	/*
	* TODO: SELECT child templates that refer to this one via Parent_Content__c
	* Dynamically assemble content
	*/
	public string getContent(){
		if(this.getAgreement() != null){
			return this.getAgreement().Content__c;
		}
		else{
			return '';
		}
	}
		
	Agreement__c m_agreement = null;
	public Agreement__c getAgreement(){
		if(m_agreement == null && m_id != null){
			m_agreement = [SELECT Id, Name, 
				Agreement_Template__c,
				Content__c,
				DocumentID__c, 
				EnvelopeID__c,
				Recipient__c,
				Recipient_Account__c,
				Sent_Date__c,
				Status__c 			
				FROM Agreement__c WHERE Id = :m_id];
		}
		return m_agreement;
	}
	
	public static testMethod void tests(){
		Template__c template = new Template__c();
		insert template;
		
		Contact c = new Contact();
		c.FirstName = 'first';
		c.LastName = 'last';
		insert c;
		
		Agreement__c agreement = new Agreement__c();
		agreement.Agreement_Template__c = template.Id;
		agreement.Recipient__c = c.Id;
		agreement.Content__c = 'test';
		insert agreement;
		
		ApexPages.currentPage().getParameters().put('id', agreement.Id);
		DSTemplateController controller = new DSTemplateController();
		
		System.assertNotEquals(null, controller.getAgreement());
		System.assertEquals('test', controller.getContent());
		System.assertEquals('', controller.Message);
	}
}