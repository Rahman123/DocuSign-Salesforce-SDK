/*
 * DSEnvelope.cls
 *
 */
global with sharing class DSEnvelope {
	public string certificateUri;
	public string customFieldsUri;
	public string documentsCombinedUri;
	public string documentsUri;
	public string envelopeId;
	public string envelopeUri;
	public string notificationUri;
	public string recipientsUri;
	public string status;
	public DateTime statusChangedDateTime;
	
	public static DSEnvelope deserialize(string jsonBody){
		return (DSEnvelope)JSON.deserialize(jsonBody, DSEnvelope.class);
	}
}