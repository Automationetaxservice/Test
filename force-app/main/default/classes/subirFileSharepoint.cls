global class subirFileSharepoint {
    @RemoteAction
    public static String uploadfile(String contactId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest(); 
        req.setMethod('POST'); 
        req.setEndpoint('https://login.microsoftonline.com/2a2ad6dd-ec53-4b85-8936-86adee4c61a6/oauth2/token'); 
        String body = 'grant_type=client_credentials' + 
            '&client_id=' + EncodingUtil.urlEncode('0207d157-7a91-4331-b414-5ef2d5e79eb4', 'UTF-8') + 
            '&client_secret='+ EncodingUtil.urlEncode('hxZ8Q~jyThowNLkIbBiVg_u1lsFQssKbGy3xyc0x', 'UTF-8') + 
            '&resource=https://graph.microsoft.com';
        req.setBody(body); 
        HttpResponse res = h.send(req); 
        String jsonString = res.getBody();
        
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonString); 
        String access_token = (String) m.get('access_token'); 
        
        String contacto = String.valueOf(contactId);
        List<Object> files = new List<Object>(); 
        List<Sharepoint__c> con = new List<Sharepoint__c>(); 
        DateTime now = System.now();
        List<Object> filesList = new List<Object>(); 
        for(ContentDocumentLink doc : [SELECT ContentDocumentId, SystemModstamp FROM ContentDocumentLink WHERE LinkedEntityId = :contacto ORDER BY Id DESC Limit 1]){ DateTime fecha = doc.SystemModstamp; Contact[] contactos = [SELECT Name FROM Contact WHERE Id = :contacto]; if(contactos.size() > 0){ String obj = '{"id":"'+doc.ContentDocumentId+'","fecha":"'+fecha.date()+'","nombreContacto":"'+contactos[0].Name+'"}'; Map<String, Object> dserialize = (Map<String, Object>)JSON.deserializeUntyped(obj); files.add((Map<String, Object>)dserialize); filesList.add(doc.ContentDocumentId); } }
        for(Object f : files){ Map<String, Object> filemap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(f)); String file = String.valueOf(filemap.get('id')); String fecha = String.valueOf(filemap.get('fecha')); String ContactName = String.valueOf(filemap.get('nombreContacto')); String ye = fecha.substringBefore('-'); String folderName = '{"name": "'+ye+'","folder": { }}'; String endPointURL = 'https://graph.microsoft.com/v1.0/sites/francistaxservicecom.sharepoint.com/drive/items/root:/' + EncodingUtil.urlEncode(ContactName, 'UTF-8').replaceAll('\\+', '%20') + ':/children'; Http ht = new Http(); HttpRequest requ = new HttpRequest(); requ.setMethod('POST'); requ.setHeader('Authorization', 'Bearer '+ access_token); requ.setHeader('Content-Type', 'application/json'); requ.setHeader('Accept', 'application/json'); requ.setEndpoint(endPointURL); requ.setBody(folderName); HttpResponse resp = ht.send(requ); ContentVersion i = [SELECT PathOnClient, VersionData, Title, FileExtension, ContentDocumentId, LastModifiedDate FROM ContentVersion WHERE ContentDocumentId= :file]; String fileName = i.Title+'.'+i.FileExtension; String endPoint = 'https://graph.microsoft.com/v1.0/sites/francistaxservicecom.sharepoint.com/drive/items/root:/'+ EncodingUtil.urlEncode(ContactName, 'UTF-8').replaceAll('\\+', '%20')+'/'+ye+'/'+ EncodingUtil.urlEncode(fileName, 'UTF-8').replaceAll('\\+', '%20')+':/content'; Http htt = new Http(); HttpRequest reque = new HttpRequest(); reque.setMethod('PUT'); reque.setHeader('Authorization', 'Bearer '+ access_token); reque.setHeader('Content-Type', 'text/plain'); reque.setHeader('Accept', 'application/json'); reque.setEndpoint(endPoint); reque.setBodyAsBlob(i.VersionData); HttpResponse respo = htt.send(reque); String Url = 'https://francistaxservicecom.sharepoint.com/_layouts/download.aspx?SourceUrl=%2FShared%20Documents%2F'+EncodingUtil.urlEncode(ContactName, 'UTF-8').replaceAll('\\+', '%20')+'%2F'+ye+'%2F'+EncodingUtil.urlEncode(fileName, 'UTF-8').replaceAll('\\+', '%20'); Sharepoint__c sharepoint = new Sharepoint__c(Contact__c=contacto,Name=fileName,Year__c=ye,DownloadUrl__c= Url,ContactName__c=ContactName, Description__c=file, Unique__c=contacto+'-'+fileName+'-'+ye); con.add(sharepoint); }
        Set<Object> set1 = new Set<Object>(); 
        List<Object> list2 = new List<Object>();
        for(Sharepoint__c c : con){ set1.add(c.Unique__c); }
        for(Sharepoint__c s : [SELECT Unique__c FROM Sharepoint__c WHERE Contact__c=:contacto]){ list2.add(s.Unique__c); }
        set1.removeAll(list2);
        for(Sharepoint__c co : con){ if(set1.contains(co.Unique__c)){ insert co; } }
        for(Object arc : filesList){ String id = String.valueOf(arc); delete [SELECT Id FROM ContentDocument WHERE Id= :id]; }
        return contacto;
    }
    @RemoteAction
    public static String deletefileSP(String recordId) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://login.microsoftonline.com/2a2ad6dd-ec53-4b85-8936-86adee4c61a6/oauth2/token');
        String body = 'grant_type=client_credentials' + 
            '&client_id=' + EncodingUtil.urlEncode('0207d157-7a91-4331-b414-5ef2d5e79eb4', 'UTF-8') + 
            '&client_secret='+ EncodingUtil.urlEncode('hxZ8Q~jyThowNLkIbBiVg_u1lsFQssKbGy3xyc0x', 'UTF-8') + 
            '&resource=https://graph.microsoft.com'; 
        req.setBody(body);
        HttpResponse res = h.send(req);
        String jsonString = res.getBody();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        String access_token = (String) m.get('access_token');
        String record = String.valueOf(recordId);
        List<Sharepoint__c> contactos = [SELECT ContactName__c, Year__c, Name FROM Sharepoint__c WHERE Id= :record limit 1];
        if(contactos.size() > 0){ String ContactName; String ye; String fileName; for(Sharepoint__c c : contactos){ ContactName = String.valueOf(c.ContactName__c); ye = String.valueOf(c.Year__c); fileName = String.valueOf(c.Name); } String endPoint = 'https://graph.microsoft.com/v1.0/sites/francistaxservicecom.sharepoint.com/drive/items/root:/'+EncodingUtil.urlEncode(ContactName, 'UTF-8').replaceAll('\\+', '%20')+'/'+ye+'/'+EncodingUtil.urlEncode(fileName, 'UTF-8').replaceAll('\\+', '%20'); Http htt = new Http(); HttpRequest reque = new HttpRequest(); reque.setMethod('DELETE'); reque.setHeader('Authorization', 'Bearer '+ access_token); reque.setHeader('Access-Control-Allow-Origin', '*'); reque.setHeader('Access-Control-Allow-Methods', 'DELETE, POST, GET, PUT, OPTIONS'); reque.setHeader('Access-Control-Allow-Headers', 'Accept, X-Requested-With, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization'); reque.setHeader('Access-Control-Expose-Headers', 'Content-Length, X-JSON'); reque.setHeader('Access-Control-Max-Age','1000'); reque.setEndpoint(endPoint); HttpResponse respo = htt.send(reque); delete[SELECT Id FROM Sharepoint__c WHERE Id= :record]; }
        return record;
    }
}