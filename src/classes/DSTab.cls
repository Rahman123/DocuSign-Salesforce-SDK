/*
 * DSTab.cls
 *
 */
public with sharing class DSTab implements DSSerializeable {
	public string name			= 'Sign here';
	public string tabId			= '';
	public string tabLabel		= '';
	
	public string documentId	= '1';
	public integer pageNumber	= 1;
	public integer xPosition	= 0;
	public integer yPosition	= 0;	
	
	public boolean useAnchorProperties = false;
	public integer anchorUnits	= 0;
	public integer anchorXOffset=0;
	public integer anchorYOffset=0;
	public string anchorString	= '';
	
	public DSTabType tabType 	= DSTabType.SIGN_HERE;
    
	public enum DSTabType {SIGN_HERE, INITIAL_HERE, FULL_NAME, EMAIL, TEXT, TITLE, COMPANY}
    public static string toPlural(DSTabType t){
    	if(t == DSTabType.SIGN_HERE){
    		return 'signHereTabs';
    	}
    	else if(t == DSTabType.INITIAL_HERE){
    		return 'initialHereTabs';
    	}
    	else if(t == DSTabType.FULL_NAME){
    		return 'fullNameTabs';
    	}
    	else if(t == DSTabType.EMAIL){
    		return 'emailTabs';
    	}
    	else if(t == DSTabType.TEXT){
    		return 'textTabs';
    	}
    	else if(t == DSTabType.TITLE){
    		return 'titleTabs';
    	}
    	else if(t == DSTabType.COMPANY){
    		return 'companyTabs';
    	}
    	else{
    		return null;
    	}
    }
    
    public JSONGenerator serialize(JSONGenerator gen){
    	gen.writeStartObject();
    	gen.writeStringField('name', this.name);
    	gen.writeStringField('tabId', this.tabId);
    	gen.writeStringField('tabLabel', this.tabLabel);
    	
    	if(this.useAnchorProperties){
    		gen.writeStringField('anchorUnits', String.valueOf(this.anchorUnits) );
    		gen.writeStringField('anchorXOffset', String.valueOf(this.anchorXOffset) );
    		gen.writeStringField('anchorYOffset', String.valueOf(this.anchorYOffset) );
    		gen.writeStringField('anchorString', this.anchorString );
    	}
    	else{	    	
	    	gen.writeStringField('documentId', this.documentId);
	    	gen.writeStringField('pageNumber', String.valueOf(this.pageNumber));
	    	gen.writeStringField('xPosition', String.valueOf(this.xPosition));
	    	gen.writeStringField('yPosition', String.valueOf(this.yPosition));
    	}
    	gen.writeEndObject();
    	return gen;
    }
    
	private static testMethod void tests(){
		DSTab tab = new DSTab();
		System.assertEquals('1', tab.documentId);
		System.assertEquals(1, tab.pageNumber);
		System.assertEquals(DSTabType.SIGN_HERE, tab.tabType);
		
		tab.name 		= 'test tab';
		tab.tabId 		= 'id';
		tab.tabLabel	= 'tab label';
		
		JSONGenerator gen = JSON.createGenerator(false);
		gen = tab.serialize(gen);
		System.assertEquals('{"name":"test tab","tabId":"id","tabLabel":"tab label","documentId":"1","pageNumber":"1","xPosition":"0","yPosition":"0"}', 
			gen.getAsString());
		
		tab.useAnchorProperties = true;
		tab.anchorString = 'signature';
		gen = JSON.createGenerator(false);
		gen = tab.serialize(gen);
		System.assertEquals('{"name":"test tab","tabId":"id","tabLabel":"tab label","anchorUnits":"0","anchorXOffset":"0","anchorYOffset":"0","anchorString":"signature"}', 
			gen.getAsString());
		
		System.assertEquals('signHereTabs', DSTab.toPlural(DSTabType.SIGN_HERE));
		System.assertEquals('initialHereTabs', DSTab.toPlural(DSTabType.INITIAL_HERE));
		System.assertEquals('fullNameTabs', DSTab.toPlural(DSTabType.FULL_NAME));
		System.assertEquals('emailTabs', DSTab.toPlural(DSTabType.EMAIL));
		System.assertEquals('textTabs', DSTab.toPlural(DSTabType.TEXT));
		System.assertEquals('titleTabs', DSTab.toPlural(DSTabType.TITLE));
		System.assertEquals('companyTabs', DSTab.toPlural(DSTabType.COMPANY));
		System.assertEquals(null, DSTab.toPlural(null));
	}
}