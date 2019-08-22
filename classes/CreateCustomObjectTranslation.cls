@RestResource (urlMapping = '/createCustomObjectTranslation')
global with sharing class CreateCustomObjectTranslation
{
    @HttpPost
    global static void createObjectTranslation(String customObjectName, String language)
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.CustomObjectTranslation customObjectTranslation = new MetadataService.CustomObjectTranslation();
        customObjectTranslation.fullName = customObjectName+'__c-'+language;
        customObjectTranslation.gender='Feminine';

        MetadataService.ObjectNameCaseValue myCaseValue1 = new MetadataService.ObjectNameCaseValue();
        myCaseValue1.value=customObjectName;
        myCaseValue1.plural=true;
        
        MetadataService.ObjectNameCaseValue myCaseValue2 = new MetadataService.ObjectNameCaseValue();
        myCaseValue2.value=customObjectName;
        myCaseValue2.plural=false;
        
        customObjectTranslation.caseValues = new List<MetadataService.ObjectNameCaseValue>();
        customObjectTranslation.caseValues.add(myCaseValue1);
        customObjectTranslation.caseValues.add(myCaseValue2);
                
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customObjectTranslation });
        handleSaveResults(results[0]);
    }
    
    public class CreateCustomObjectTranslationException extends Exception { }

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
                throw new CreateCustomObjectTranslationException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new CreateCustomObjectTranslationException('Request failed with no specified error.');
    }
}