@isTest
public class SingleRequestMockTest implements HttpCalloutMock {
    protected Integer code;
    protected String status;
    protected String bodyAsString;
    protected Blob bodyAsBlob;
    protected List<String> responseHeaders;
    
    public SingleRequestMockTest(Integer code, String status, String body, List<String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.bodyAsString = body;
        this.bodyAsBlob = null;
        this.responseHeaders = responseHeaders;
    }
    public SingleRequestMockTest(Integer code, String status, Blob body, List<String> responseHeaders) {
        this.code = code;
        this.status = status;
        this.bodyAsBlob = body;
        this.bodyAsString = null;
        this.responseHeaders = responseHeaders;
    }
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse resp = new HttpResponse();
        resp.setStatusCode(code);
        resp.setStatus(status);
        if (bodyAsBlob != null) {
            resp.setBodyAsBlob(bodyAsBlob);
        }else{
            resp.setBody(bodyAsString);
        }
        return resp;
    }
}