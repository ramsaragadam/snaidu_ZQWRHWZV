@RestResource (urlMapping = '/deleteProfile/*')
global class DeleteProfile
{
    @HttpDelete
    global static void deleteProfile()
    {
        String profileName = RestContext.request.params.get('profileName');
        MetadataService.MetadataPort service = createService();
        String[] fullnames = new String[] {profileName};
        List<MetadataService.DeleteResult> results =  service.deleteMetadata('Profile', fullnames);
        handleDeleteResults(results[0]);
    }

    public class DeleteProfileException extends Exception { }

    public static MetadataService.MetadataPort createService()
    {
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;
    }

    public static void handleDeleteResults(MetadataService.DeleteResult deleteResult)
    {
        if(deleteResult==null || deleteResult.success)
            return;
        if(deleteResult.errors!=null)
        {
            List<String> messages = new List<String>();
            messages.add(
                (deleteResult.errors.size()==1 ? 'Error ' : 'Errors ') +
                    'occured processing component ' + deleteResult.fullName + '.');
            for(MetadataService.Error error : deleteResult.errors)
                messages.add(
                    error.message + ' (' + error.statusCode + ').' +
                    ( error.fields!=null && error.fields.size()>0 ?
                        ' Fields ' + String.join(error.fields, ',') + '.' : '' ) );
            if(messages.size()>0)
                throw new DeleteProfileException(String.join(messages, ' '));
        }
        if(!deleteResult.success)
            throw new DeleteProfileException('Request failed with no specified error.');
    }
}