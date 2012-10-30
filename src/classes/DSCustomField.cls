public with sharing class DSCustomField {
	public string name;
	public boolean show;
	public boolean required;
	public string value;
	
	public static testMethod void persitenceTests(){
		DSCustomField field = new DSCustomField();
		field.name = 'foo';
		field.show = true;
		field.required = true;
		field.value = 'foo';
		
		System.assertEquals('foo', field.name);
		System.assertEquals('foo', field.value);
		System.assertEquals(true, field.show);
		System.assertEquals(true, field.required);
	}
}