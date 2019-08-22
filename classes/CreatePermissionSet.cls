@RestResource (urlMapping = '/createPermissionSet')
global with sharing class CreatePermissionSet
{
    @HttpPost
    global static void createPermissionSet(String permissionSetName)
    {
        MetadataService.MetadataPort service = createService();
        MetadataService.PermissionSet ps = new MetadataService.PermissionSet();
        ps.fullName=permissionSetName;
        ps.description=permissionSetName+' Bot description';
        ps.label=permissionSetName;

        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { ps });
        handleSaveResults(results[0]);
    }
    
    public class CreatePermissionSetException extends Exception { }

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
                throw new CreatePermissionSetException(String.join(messages, ' '));
        }
        if(!saveResult.success)
            throw new CreatePermissionSetException('Request failed with no specified error.');
    }
}