/*
 * DSSignatureRequest.cls
 * 
 * Structured class passed to the DSClient.requestSignature() method.
 * Note: Currently does not support Tabs
 */
global with sharing class DSSignatureRequest {
	public boolean fromTemplate = false;
	public boolean fromDocument = false;
	public string emailSubject;
	public string emailBlurb;
	public string templateId;
	public DSEnvelopeStatus status 				= DSEnvelopeStatus.Sent;
	public List<DSDocument> documents			= new List<DSDocument>();
	public List<DSCustomField> customFields		= new List<DSCustomField>();
	public List<DSTemplateRole> templateRoles	= new List<DSTemplateRole>();
	public List<DSRecipient> recipients			= new List<DSRecipient>();
	
	public string serialize(){
		/*
		 * if from document, then render header first
		 --myBoundary
		 Content-Disposition: form-data
		 */
		JSONGenerator gen = JSON.createGenerator(false);
		gen.writeStartObject();
		gen.writeStringField('emailSubject', this.emailSubject);
		gen.writeStringField('emailBlurb', this.emailBlurb);
		gen.writeStringField('templateId', this.templateId);		
		gen.writeStringField('status', (this.status == DSEnvelopeStatus.Sent ? 'sent':'created') );
		
		if(this.customFields.size() > 0){
			gen.writeFieldName('customFields');
			gen.writeStartObject();
			
			List<DSCustomField> fieldList = this.getFieldsByType(DSCustomField.DSCustomFieldType.LIST_FIELD);
			if(fieldList.size() > 0){
				gen.writeFieldName('listCustomFields');
				gen.writeStartArray();
				for(DSCustomField f : fieldList){
					gen = f.serialize(gen);
				}
				gen.writeEndArray();
			}
			fieldList.clear();
			fieldList = this.getFieldsByType(DSCustomField.DSCustomFieldType.TEXT_FIELD);
			if(fieldList.size() > 0){
				gen.writeFieldName('textCustomFields');
				gen.writeStartArray();
				for(DSCustomField f : fieldList){
					gen = f.serialize(gen);
				}
				gen.writeEndArray();
			}
			gen.writeEndObject();
		}
		
		if(this.templateRoles.size() > 0){
			gen.writeFieldName('templateRoles');
			gen.writeStartArray();
			for(DSTemplateRole role : this.templateRoles){
				gen = role.serialize(gen);
			}
			gen.writeEndArray();
		}
		gen.writeEndObject();
		gen.close();
		return gen.getAsString();
	}
	
	private List<DSCustomField> getFieldsByType(DSCustomField.DSCustomFieldType fieldType){
		List<DSCustomField> result = new List<DSCustomField>();
		for(DSCustomField f : this.customFields){
			if(f.fieldType == fieldType){
				result.add(f);
			}
		}
		return result;
	}
	
	private static testMethod void persistenceTests(){
		DSSignatureRequest request = new DSSignatureRequest();
		request.emailBlurb = 'foo';
		request.emailSubject = 'foo';
		request.templateId = 'foo';
		
		System.assertEquals('foo', request.emailBlurb);
		System.assertEquals('foo', request.emailSubject);
		System.assertEquals(0, request.customFields.size());
		System.assertEquals(0, request.templateRoles.size());
	}
	
	private static testMethod void getFieldByTypeTests(){
		DSSignatureRequest request = new DSSignatureRequest();		
		request.customFields.add( new DSCustomField('name', 'value') );
		
		DSCustomField listField = new DSCustomField('name', 'value');
		listField.fieldType = DSCustomField.DSCustomFieldType.LIST_FIELD;
		listField.listItems.add('item1');
		listField.listItems.add('item2');
		request.customFields.add( listField );
		
		System.assertEquals(1, request.getFieldsByType(DSCustomField.DSCustomFieldType.LIST_FIELD).size() );
		System.assertEquals(1, request.getFieldsByType(DSCustomField.DSCustomFieldType.TEXT_FIELD).size() );
	}
	
	private static testMethod void serializeTests(){
		DSSignatureRequest request = new DSSignatureRequest();
		request.emailSubject = 'please sign';
		request.emailBlurb = 'click here';
		request.templateId = 'template id';
		
		request.customFields.add( new DSCustomField('fname1', 'fvalue1') );
		request.customFields.add( new DSCustomField('fname2', 'fvalue2') );
		
		DSCustomField listField = new DSCustomField('fname3', 'fvalue3');
		listField.fieldType = DSCustomField.DSCustomFieldType.LIST_FIELD;
		listField.listItems.add('item1');
		listField.listItems.add('item2');
		listField.listItems.add('item3');
		request.customFields.add( listField );
		
		request.templateRoles.add( new DSTemplateRole('name@domain.com', 'name', 'Signer'));
		
		string expectedJSON = '{"emailSubject":"please sign","emailBlurb":"click here","templateId":"template id","status":"sent","customFields":{"listCustomFields":[{"name":"fname3","value":"fvalue3","show":false,"required":false,"listItems":["item1,item2,item3"]}],"textCustomFields":[{"name":"fname1","value":"fvalue1","show":false,"required":false},{"name":"fname2","value":"fvalue2","show":false,"required":false}]},"templateRoles":[{"email":"name@domain.com","name":"name","roleName":"Signer"}]}';
		string actualJSON = request.serialize();
		System.assertEquals(expectedJSON, actualJSON);
	}
}