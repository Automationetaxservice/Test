global class eliminarFileSharepoint {
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