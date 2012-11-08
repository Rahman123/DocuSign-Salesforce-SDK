/*
 * DSTemplateRole.cls
 *
 */
global with sharing class DSTemplateRole implements DSSerializeable{
	public string email;
	public string name;
	public string roleName;
	public List<DSTab> tabs = new List<DSTab>();
	
	public DSTemplateRole(){}
	
	public DSTemplateRole(string inputEmail, string inputName, string inputRoleName){
		this.email 		= inputEmail;
		this.name		= inputName;
		this.roleName 	= inputRoleName;
	}
	
	public JSONGenerator serialize(JSONGenerator gen){
		gen.writeStartObject();
		gen.writeStringField('email', this.email);
		gen.writeStringField('name', this.name);		
		gen.writeStringField('roleName', this.roleName);
		gen.writeEndObject();
		return gen;
	}
	
	private static testMethod void serializeTests(){
		DSTemplateRole role = new DSTemplateRole();
		role.name 		= 'name';
		role.email 		= 'name@domain.com';		
		role.roleName 	= 'Signer';
		
		string expectedJSON = '{"email":"name@domain.com","name":"name","roleName":"Signer"}';
		JSONGenerator gen = JSON.createGenerator(false);
		gen = role.serialize(gen);
		string actualJSON = gen.getAsString();
		System.assertEquals(expectedJSON, actualJSON);
	}
	
	private static testMethod void persistenceTests(){
		DSTemplateRole role = new DSTemplateRole();
		role.email = 'foo';
		role.name = 'foo';
		role.roleName = 'foo';
		
		System.assertEquals('foo', role.email);
		System.assertEquals('foo', role.name);
		System.assertEquals('foo', role.roleName);
		
		role = new DSTemplateRole('name@domain.com', 'name', 'role name');
		System.assertEquals('name@domain.com', role.email);
		System.assertEquals('name', role.name);
		System.assertEquals('role name', role.roleName);
	}
}