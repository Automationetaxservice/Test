@isTest
public class inactivecontactfiles_test {
    public static testmethod void testAccessTokenCallout() {
        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200, 'Complete', '{"access_token": "eyJ0eXAiOiJKV1QiLCJub25jZSI6IkEyUGxKTWdlYldyZ2MyZUxIQkd6QlJUbkFmMFM1YzF4UlQxckhrcGdxTlkiLCJhbGciOiJSUzI1NiIsIng1dCI6IjVCM25SeHRRN2ppOGVORGMzRnkwNUtmOTdaRSIsImtpZCI6IjVCM25SeHR"}', null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        inactivecontactfiles.getAccessToken();
    }
    /*
    public static testmethod void testUploadFileCallout() {
        SingleRequestMockTest fakeResponse = new SingleRequestMockTest(200, 'Complete', '{"@microsoft.graph.downloadUrl": "https://francistaxservicecom.sharepoint.com/_layouts/15/download.aspx?UniqueId=2309bf79-14b5-4dc4-a191-7936aa488127&Translate=false&tempauth=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJhdWQiOiIwMDAwMDAwMy0wMDAwLTBmZjEtY2UwMC0wMDAwMDAwMDAwMDAvZnJhbmNpc3RheHNlcnZpY2Vjb20uc2hhcmVwb2ludC5jb21AMmEyYWQ2ZGQtZWM1My00Yjg1LTg5MzYtODZhZGVlNGM"}', null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);
        InactiveContactFiles.uploadfiles();
    }
	*/
}