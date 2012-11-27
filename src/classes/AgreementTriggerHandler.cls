public with sharing class AgreementTriggerHandler {
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	
	public AgreementTriggerHandler(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
	}
	
	public void OnBeforeInsert(Agreement__c[] newAgreements){
		Map<id,Template__c> templateMap = new Map<id,Template__c>([SELECT Id,Name, Type__c, Content__c FROM Template__c limit 50000]);
		
		//TODO: Dynamic merge templating.
		/* move to preview button
		 * 
		 */  
		for(Agreement__c newAgreement : newAgreements){
			Template__c template = templateMap.get(newAgreement.Agreement_Template__c);
			if(template != null && template.Content__c != null && template.Content__c != ''){
				newAgreement.Content__c = template.Content__c;
			}
		}
	}
	/*
	public void OnAfterInsert(Agreement__c[] newAgreements){}
	
	@future public static void OnAfterInsertAsync(Set<ID> newAgreementIDs){}
	
	public void OnBeforeUpdate(Agreement__c[] oldAccounts, Agreement__c[] updatedAccounts, Map<ID, Agreement__c> agreementMap){}
	
	public void OnAfterUpdate(Agreement__c[] oldAccounts, Agreement__c[] updatedAccounts, Map<ID, Agreement__c> agreementMap){}
	
	@future public static void OnAfterUpdateAsync(Set<ID> updatedAgreementIDs){}
	
	public void OnBeforeDelete(Agreement__c[] accountsToDelete, Map<ID, Agreement__c> agreementMap){}
	
	public void OnAfterDelete(Agreement__c[] deletedAccounts, Map<ID, Agreement__c> agreementMap){}
	
	@future public static void OnAfterDeleteAsync(Set<ID> deletedAgreementIDs){	}
	
	public void OnUndelete(Agreement__c[] restoredAgreements){}
	*/
	
	public boolean IsTriggerContext{
		get{ return m_isExecuting;}
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
		insert agreement;
		
		List<Agreement__c> agreementList = new List<Agreement__c>();
		agreementList.add(agreement);
		
		AgreementTriggerHandler handler = new AgreementTriggerHandler(true, 100);
		
		handler.OnBeforeInsert(agreementList);
		
		System.assertEquals(true, handler.IsTriggerContext);
	}
}