@RestResource (urlMapping = '/createCustomObject')
global with sharing class CreateCustomObject
{
    @HttpPost
    global static void createObject(String customObjectName)
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomObject customObject = new MetadataService.CustomObject();
        customObject.fullName = customObjectName+'__c';
        customObject.label = customObjectName;
        customObject.pluralLabel = customObjectName+'s';
        customObject.nameField = new MetadataService.CustomField();
        customObject.nameField.type_x = 'Text';
        customObject.nameField.label = 'Test Record';
        customObject.deploymentStatus = 'Deployed';
        customObject.sharingModel = 'ReadWrite';
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customObject });
        handleSaveResults(results[0]);
    }
    
    public class CreateCustomObjectException extends Exception { }

    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }


    public static void handleSaveResults(MetadataService.SaveResult saveResult)
    {
        if(saveResult==null || saveResult.success)
            return;
        if(saveResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (saveResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + saveResult.fullName + '.');
            for(MetadataService.Error error : saveResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new CreateCustomObjectException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new CreateCustomObjectException('Request failed with no specified error.');
    }
}