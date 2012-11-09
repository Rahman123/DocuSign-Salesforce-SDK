/*
 * DSRecipient.cls
 * 
 */
public with sharing class DSRecipient implements DSSerializeable {
	public enum DSRecipientRole {SIGNER, IN_PERSON_SIGNER, EDITOR, AGENT, INTERMEDIARY, CARBON_COPY}
	public DSRecipientRole role = DSRecipientRole.SIGNER;
	
	// Used by all roles
	public string email			= '';
	public string name			= '';
	public string recipientId 	= '1';
	
	// Variable use (enforced by validate() )	
	public string clientUserId	= '';
	public string routingOrder	= '';
	public string hostName		= '';
	
	public DSEmailNotification emailNotification;
	public DSSignatureInfo signatureInfo;
	public List<DSTab> tabs = new List<DSTab>();
		
	public JSONGenerator serialize(JSONGenerator gen){
		gen.writeStartObject();
		gen.writeStringField('email', this.email);
		gen.writeStringField('name', this.name);
		gen.writeStringField('recipientId', this.recipientId);
		gen.writeEndObject();
		return gen;
	}
	
	private static testMethod void tests(){
		DSRecipient recipient = new DSRecipient();
		recipient.name	= 'First Last';
		recipient.email = 'name@domain.com';
		System.assertEquals('name@domain.com', recipient.email);
		System.assertEquals(DSRecipientRole.SIGNER, recipient.role);
		
		recipient.tabs.add(new DSTab());
		System.assertEquals(1, recipient.tabs.size());
		
		JSONGenerator gen = JSON.createGenerator(false);
		string EXPECTED_JSON = '{"email":"name@domain.com","name":"First Last","recipientId":"1"}';
		System.assertEquals(EXPECTED_JSON, recipient.serialize(gen).getAsString());
	}
}