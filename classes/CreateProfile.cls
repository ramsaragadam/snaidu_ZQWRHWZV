@RestResource (urlMapping = '/createProfile')
global with sharing class CreateProfile
{
    @HttpPost
    global static void createProfile(String profileName)
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.Profile profile = new MetadataService.Profile();
        profile.fullName = profileName;
        profile.description = profileName + ' description';
        profile.userLicense = 'Salesforce';
        profile.custom = false;
      
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { profile });
        handleSaveResults(results[0]);
    }
    
    public class CreateProfileException extends Exception { }

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
                throw new CreateProfileException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new CreateProfileException('Request failed with no specified error.');
    }
}