public with sharing class DSTemplateRole {
	public string email;
	public string name;
	public string roleName;
	
	public static testMethod void persistenceTests(){
		DSTemplateRole role = new DSTemplateRole();
		role.email = 'foo';
		role.name = 'foo';
		role.roleName = 'foo';
		
		System.assertEquals('foo', role.email);
		System.assertEquals('foo', role.name);
		System.assertEquals('foo', role.roleName);
	}
}