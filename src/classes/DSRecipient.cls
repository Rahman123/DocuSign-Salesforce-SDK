/*
 * DSRecipient.cls
 * 
 */
public with sharing class DSRecipient implements DSSerializeable {
	public enum DSRecipientRole {SIGNER, IN_PERSON_SIGNER, EDITOR, AGENT, INTERMEDIARY, CARBON_COPY}
	
	// Used by all roles
	public string email;
	public string name;
	public string recipientId;
	
	// Variable use (enforced by validate() )	
	public string clientUserId;
	public string routingOrder;
	public string hostName;		
	
	public DSEmailNotification emailNotification;
	public DSSignatureInfo signatureInfo;
	public List<DSTab> tabs = new List<DSTab>();
	
	public static string toPlural(DSRecipientRole role){
		if(role == DSRecipientRole.SIGNER){
			return 'signers';
		}
		else if(role == DSRecipientRole.IN_PERSON_SIGNER){
			return 'inPersonSigners';
		}
		else if(role == DSRecipientRole.EDITOR){
			return 'editors';
		}
		else if(role == DSRecipientRole.AGENT){
			return 'agents';
		}
		else if(role == DSRecipientRole.INTERMEDIARY){
			return 'intermediaries';
		}
		else if(role == DSRecipientRole.CARBON_COPY){
			return 'carbonCopies';
		}
		else{
			return null;
		}
	}
	
	public JSONGenerator serialize(JSONGenerator gen){
		gen.writeStartObject();
		gen.writeStringField('email', this.email);
		gen.writeStringField('name', this.name);
		gen.writeStringField('recipientId', this.recipientId);
		gen.writeEndObject();
		return gen;
	}
	
	private static testMethod void toPluralTests(){
		System.assertEquals('signers', DSRecipient.toPlural(DSRecipientRole.SIGNER));
		System.assertEquals('inPersonSigners', DSRecipient.toPlural(DSRecipientRole.IN_PERSON_SIGNER));
		System.assertEquals('editors', DSRecipient.toPlural(DSRecipientRole.EDITOR));
		System.assertEquals('agents', DSRecipient.toPlural(DSRecipientRole.AGENT));
		System.assertEquals('intermediaries', DSRecipient.toPlural(DSRecipientRole.INTERMEDIARY));
		System.assertEquals('carbonCopies', DSRecipient.toPlural(DSRecipientRole.CARBON_COPY));
		System.assertEquals(null, DSRecipient.toPlural(null));
		
		DSRecipient recipient = new DSRecipient();
		recipient.email = 'name@domain.com';
		System.assertEquals('name@domain.com', recipient.email);
		
		recipient.tabs.add(new DSTab());
		System.assertEquals(1, recipient.tabs.size());
	}
}