global class inactivecontactfiles {
    //Solicitar token
	webservice static String getAccessToken() {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('https://login.microsoftonline.com/2a2ad6dd-ec53-4b85-8936-86adee4c61a6/oauth2/token');
        String body = 'grant_type=client_credentials'+
            '&client_id=' + EncodingUtil.urlEncode('0207d157-7a91-4331-b414-5ef2d5e79eb4', 'UTF-8') +
            '&client_secret='+ EncodingUtil.urlEncode('hxZ8Q~jyThowNLkIbBiVg_u1lsFQssKbGy3xyc0x', 'UTF-8') +
            '&resource=https://graph.microsoft.com';
        req.setBody(body);
        HttpResponse res = h.send(req);
        String jsonString = res.getBody();
        return jsonString;
    }
    //Separar token de respuesta JSON
    webservice static String deserializeAccessToken(){
        String jsonString = inactivecontactfiles.getAccessToken();
        Map<String, Object> m = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        String access_token = (String) m.get('access_token');
        return access_token;
    }
    webservice static void uploadfiles(){
        String access_token = inactivecontactfiles.deserializeAccessToken();
		String driveID = 'b!jgQcTxMbA0ynJvhGAvMsviXCxgZ_vUFDobXCoD0QPC2Qkz3G5D8NToTfMNrRGRpJ';
        
		List<String> contactnoms = new List<String>(); //Guardar nombres en esta lista
        List<String> ids = new List<String>(); //Guardar ids de documentos en esta lista
        //Buscar ids y nombres de contactos inactivos
        for(Contact inactivos : [SELECT Id, Name FROM Contact WHERE Isactive__c = false]){
            String id = String.valueOf(inactivos.Id); //Convertir id de tipo objeto a String, para comparar en query SOQL
            //Obtener ids de documentos
            for(ContentDocumentLink a : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId= :id]){
                ids.add(a.ContentDocumentId); //Guardar ids en lista
                //Obtener nombres igual que orden de documentos
                contactnoms.add(inactivos.Name); //Guardar nombres en lista
            }
            //Crear folders de contactos
            String folderBody = '{"name": "'+inactivos.Name+'","folder": { },"@microsoft.graph.conflictBehavior": "rename"}';
            string endPoint = 'https://graph.microsoft.com/v1.0/drives/' + 
                EncodingUtil.urlEncode(driveID, 'UTF-8').replaceAll('\\+', '%20') +
                '/root/children';
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer '+ access_token);
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('Accept', 'application/json');
            req.setEndpoint(endPoint);
            req.setBody(folderBody);
            HttpResponse res = h.send(req);
        }
        //Ciclo con respecto al tamaño de lista de nombres
        Integer j = 0;
        while(j < contactnoms.size()){
            for(Object b : ids){
                String id = String.valueOf(b);
                for(ContentVersion i : [SELECT PathOnClient, VersionData, Title, FileExtension FROM ContentVersion WHERE ContentDocumentId= :id]){
                    String folderName = contactnoms[j];
                    String fileName = i.PathOnClient;
                    String endPoint = 'https://graph.microsoft.com/v1.0/drives/' + 
                        EncodingUtil.urlEncode(driveID, 'UTF-8').replaceAll('\\+', '%20') +
                        '/root:/'+EncodingUtil.urlEncode(folderName, 'UTF-8').replaceAll('\\+', '%20')+'/'+
                        EncodingUtil.urlEncode(fileName, 'UTF-8').replaceAll('\\+', '%20')+':/content';
                    Http ht = new Http();
                    HttpRequest requ = new HttpRequest();
                    requ.setMethod('PUT');
                    requ.setHeader('Authorization', 'Bearer '+ access_token);
                    requ.setHeader('Content-Type', 'text/plain');
                    requ.setHeader('Accept', 'application/json');
                    requ.setEndpoint(endPoint);
                    requ.setBodyAsBlob(i.VersionData);
                    HttpResponse resp = ht.send(requ);
                }
                j++;
            }
        }
    }
}