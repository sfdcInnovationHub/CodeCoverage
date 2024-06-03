@isTest
public class RunAllTstClassesControllerTest {
    
	@isTest
    public static void getTestClassesTest(){
        ApexClass[] testClasses = RunAllTstClassesController.getTestClasses();
    }
    
    @isTest
    public static void fetchRecordsTest(){
        String searchWord = 'c';
        List<ApexClass> testClasses = RunAllTstClassesController.fetchRecords(searchWord);
    }
    
    @isTest
    public static void runSelectedTest(){
        List<Id> testClassesId = new List<Id>();
        testClassesId.add('01p000000000001AAA');
        RunAllTstClassesController.runSelected(testClassesId);
    }
    
    @isTest
    public static void runAllTest(){
        RunAllTstClassesController.runAll();
    }
    
    @isTest
    public static void checkStatusTest(){
        Id currentId = '01p000000000001AAA';
        RunAllTstClassesController.checkStatus(currentId);
    }
    private class HttpMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"ApexCodeCoverage","records":[{"attributes":{"type":"ApexCodeCoverage","url":"/services/data/v59.0/tooling/sobjects/ApexCodeCoverage/714J400000058jwIAA"},"Id":"714J400000058jwIAA","ApexClassOrTrigger":{"attributes":{"type":"Name","url":"/services/data/v59.0/tooling/sobjects/ApexClass/01p5j00000ecuRfAAI"},"Name":"xyzClass"},"ApexTestClass":{"attributes":{"type":"ApexClass","url":"/services/data/v59.0/tooling/sobjects/ApexClass/01p5j00000ecuRpAAI"},"Name":"xyz"},"Coverage":{"coveredLines":[2,3,4,5,6,7,8,9,10,11,12,13,14],"uncoveredLines":[15,16,17,18,19,20]}}, {"attributes":{"type":"ApexCodeCoverage","url":"/services/data/v59.0/tooling/sobjects/ApexCodeCoverage/714J400000058jwIAA"},"Id":"714J400000058jwIAA","ApexClassOrTrigger":{"attributes":{"type":"Name","url":"/services/data/v59.0/tooling/sobjects/ApexClass/01p5j00000ecuRfAAI"},"Name":"xyzClass"},"ApexTestClass":{"attributes":{"type":"ApexClass","url":"/services/data/v59.0/tooling/sobjects/ApexClass/01p5j00000ecuRpAAI"},"Name":"abc"},"Coverage":{"coveredLines":[7,8,9,10,11],"uncoveredLines":[2,3,4,5,6,15,16,17,18,19,20]}}]}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    @isTest
    public static void getApexCodeCoverageTest() {
        Test.setMock(HttpCalloutMock.class, new HttpMock());
        Test.startTest();
        List<String> testClasses = new List<String>();
        testClasses.add('xyz');
        testClasses.add('abc');
        RunAllTstClassesController.getCodeCoverageForEachTest(testClasses);
        Test.stopTest();
    }
    
    @isTest
    public static void CodeCoverageEachClassTest(){
        Test.setMock(HttpCalloutMock.class, new HttpMock());
        Test.startTest();
        List<String> classNameList = new List<String>();
        classNameList.add('xyzClass');
        //classNameList.add('abcClass');
        RunAllTstClassesController.CodeCoverageEachClass(classNameList);
        Test.stopTest();
    }
}