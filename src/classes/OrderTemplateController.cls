public with sharing class OrderTemplateController {
	public string Message {get; set;}
	Id m_id 			= null;
	
	public OrderTemplateController(){
		m_id = ApexPages.currentPage().getParameters().get('id');
		if(m_id == null){
			Message = 'Missing id parameter. View an Order record and click on "Preview Order" to see this template in action.';
		}
		else{
			Message = '';
		}
	}
	
	Order__c m_order	= null;
	public Order__c getOrder(){
		if(m_order == null && m_id != null){
			m_order = [SELECT Id, Name, Account__r.Name, Account__r.AccountNumber,
				Account__r.BillingStreet, 
				Account__r.BillingCity, 
				Account__r.BillingCountry,
				Account__r.BillingPostalCode,
				Account__r.BillingState,
				Account__r.ShippingStreet,
				Account__r.ShippingCity, 
				Account__r.ShippingCountry,
				Account__r.ShippingPostalCode,
				Account__r.ShippingState,
				Warranty_Included__c ,
				Opportunity__c, Order_Total__c FROM Order__c WHERE Id = :m_id];
		}
		return m_order;
	}
	
	List<Order_Line_Item__c> m_lineItems = null;
	public List<Order_Line_Item__c> getLineItems() {
		if(m_lineItems == null && m_id != null){ 
			m_lineItems = [select Id, Name, Price__c, Product__c, Product__r.Name, Quantity__c,Total__c, Order__c from Order_Line_Item__c where Order__c=:m_id];
		}
		return m_lineItems;
	}
}