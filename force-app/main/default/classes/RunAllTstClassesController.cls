public with sharing class  RunAllTstClassesController {
    
    @AuraEnabled
    //Fetch all the test classes present in the org
    public static List<ApexClass> getTestClasses(){
        ApexClass[] testClasses = [FIND '@isTest' IN ALL FIELDS RETURNING ApexClass(Id, Name, Status, Body, CreatedDate WHERE Name LIKE '%Test%')][0];
        return testClasses;
    }
    
    @AuraEnabled
    //Fetch the test classes as per the search keyword
    public static List<ApexClass> fetchRecords(String searchWord){
        String modifiedKeyWord =  searchWord + '%Test%';
        ApexClass[] fetchedList = [FIND '@isTest' IN ALL FIELDS RETURNING ApexClass(Id, Name, Status, Body, CreatedDate WHERE Name LIKE: modifiedKeyWord)][0];
        return fetchedList;
    }
    
    @AuraEnabled
    //Run the selected test classes.
    public static Id runSelected(List<Id> testClassesId){
        List<ApexTestQueueItem> testQueueItems = new List<ApexTestQueueItem>();
        for(Id eachRecord : testClassesId){
            ApexTestQueueItem testQueueItem = new ApexTestQueueItem();
            testQueueItem.ApexClassId = eachRecord;
            testQueueItems.add(testQueueItem);
        }
        //For the test class.
        if(Test.isRunningTest()){
            return '01p000000000001AAA';
        }
        else{
            insert testQueueItems;
            ApexTestQueueItem item = [SELECT ParentJobId FROM ApexTestQueueItem WHERE Id =: testQueueItems[0].Id LIMIT 1];
            return item.ParentJobId;
        }
    }
    
	@AuraEnabled 
    // Run all the test classes present in the org. 
    public static Map<Id, Integer> runAll(){
        List<ApexClass> scope = new List<ApexClass>([SELECT Id, Name FROM ApexClass WHERE Name LIKE '%Test%']);
        Integer numberOfTestClasses = scope.size();
        List<ApexTestQueueItem> testQueueItems = new List<ApexTestQueueItem>();
        List<Id> idList = new List<Id>();
        for (ApexClass testClass : scope){
            ApexTestQueueItem testQueueItem = new ApexTestQueueItem();
            testQueueItem.ApexClassId = testClass.Id;
            idList.add(testClass.Id);
            testQueueItems.add(testQueueItem);
        }
        Map<Id, Integer> returnMap = new Map<Id, Integer>();
        //For the test classs.
        if(Test.isRunningTest()){
            returnMap.put('01p000000000001AAA', 1);
            return returnMap;
        }
        else{
            insert testQueueItems;
            Id tempId = testQueueItems[0].Id;
            ApexTestQueueItem temp = new ApexTestQueueItem();
            temp = [SELECT ParentJobId FROM ApexTestQueueItem WHERE Id =: tempId LIMIT 1];
            returnMap.put(temp.ParentJobId, numberOfTestClasses);
            return returnMap;
        
        }
    }
    @AuraEnabled
    // Check the status of the running test classes.
    public static List<ApexTestResult> checkStatus(Id currentId){
        AsyncApexJob testRequestJobStatus = new AsyncApexJob();
        List<ApexTestResult> testResults = new List<ApexTestResult>();
        if(!Test.isRunningTest()){
            testRequestJobStatus = [SELECT  Status FROM AsyncApexJob WHERE Id =: currentId LIMIT 1];
            List<ApexTestQueueItem> testClassesStatus = new List<ApexTestQueueItem>([SELECT Status FROM ApexTestQueueItem WHERE ParentJobId =: currentId]);
            for(ApexTestQueueItem record : testClassesStatus){
                if(record.Status == 'Completed'){
                    testResults = [SELECT ApexClass.Name, Outcome, MethodName, Message, StackTrace, SystemModstamp FROM ApexTestResult WHERE AsyncApexJobId =: currentId];
                }
                // For the test class.
                else{
                   return testResults;
                }
            }
            //end of 'for' loop.
            return testResults;
        }
        //When test class is running.
        else{
            return testResults;
        }
    }
    @AuraEnabled
    //Get the code coverage of all the classes that were involved with test Classes
    public static List<String> getCodeCoverageForEachTest(List<String> testClasses){
        String queryData = '(';
        for(integer i = 0; i < testClasses.size(); i++){
            String eachTestClass = testClasses[i];
            eachTestClass = '\'' + eachTestClass + '\'';
            queryData = queryData + eachTestClass;
            if(i < testClasses.size() -1){
                queryData = queryData + ',';
            }
        }
        queryData = queryData + ')';
        String toolingSOQL = '/services/data/v59.0/tooling/query?q=SELECT+Id+,+ApexClassOrTrigger.Name+,+ApexTestClass.Name+,+Coverage+FROM+ApexCodeCoverage+WHERE+ApexTestClass.Name+IN+';
        toolingSOQL = toolingSOQL + queryData;
        String baseURL = 'callout:ToolingAPI';
        String endpoint = baseURL+toolingSOQL;       
        Http newReq = new Http();
        HttpRequest hreq = new HttpRequest();
        hreq.setHeader('Content-Type', 'application/json');
        hreq.setEndpoint(endpoint);
        hreq.setMethod('GET');
        HttpResponse hresp = NewReq.send(hreq);
        String body = hresp.getBody();
        JsonApexCodeCoverage bodyResult = JsonApexCodeCoverage.parse(body);             //Body Result received through the API callout has been parsed into JSON format.
                                                                                        //Wrapper class is written in JsonApexCodeCoverage class.
        List<String> data = new List<String>();
        for(String test : testClasses){
        	for(JsonApexCodeCoverage.Records singleRecord : bodyresult.Records){
                //The processed data has been again wrapped.
                if(singleRecord.ApexTestClass.Name == test){
                    CodeCoverageWrapperClass newInstance = new CodeCoverageWrapperClass(test, singleRecord.ApexClassOrTrigger.Name, singleRecord.Coverage.coveredLines, singleRecord.Coverage.uncoveredLines);
                    data.add(JSON.serialize(newInstance));
                }
            }
        }
        return data;
    }
    
    @AuraEnabled
    // Get the Org code coverage of the classes involved with the test classes.
    public static Map<String, Decimal> codeCoverageEachClass(List<String> classNameList){
       String queryData = '(';
       for(integer i = 0; i < classNameList.size(); i++){
            String eachClassName = classNameList[i];
            eachClassName = '\'' + eachClassName + '\'';
            queryData = queryData + eachClassName;
            if(i < classNameList.size() -1){
                queryData = queryData + ',';
            }
        }
        queryData = queryData + ')';
        String toolingSOQL = '/services/data/v59.0/tooling/query?q=SELECT+Id+,+ApexClassOrTrigger.Name+,+ApexTestClass.Name+,+Coverage+FROM+ApexCodeCoverage+WHERE+ApexClassOrTrigger.Name+IN+';
        toolingSOQL = toolingSOQL + queryData;
        String baseURL = 'callout:ToolingAPI';
        String endpoint = baseURL+toolingSOQL;        
        Http newReq = new Http();
        HttpRequest hreq = new HttpRequest();
        hreq.setHeader('Content-Type', 'application/json');
        hreq.setEndpoint(endpoint);
        hreq.setMethod('GET');
        HttpResponse hresp = NewReq.send(hreq);
        String body = hresp.getBody();
        JsonApexCodeCoverage bodyResult = JsonApexCodeCoverage.parse(body);
        
        Map<String, Set<Integer>> covered = new Map<String, Set<Integer>>();
        Map<String, Set<Integer>> unCovered = new Map<String, Set<Integer>>();
        Map<String, Decimal> percetageCoverageMap = new Map<String, Decimal>();
        
        for(JSONApexCodeCoverage.Records singleRecord : bodyresult.Records){
            if(covered.containsKey(singleRecord.ApexClassOrTrigger.Name)){
                covered.get(singleRecord.ApexClassOrTrigger.Name).addAll(singleRecord.Coverage.coveredLines);
                unCovered.get(singleRecord.ApexClassOrTrigger.Name).addAll(singleRecord.Coverage.uncoveredLines);
            }
            else{
                covered.put(singleRecord.ApexClassOrTrigger.Name, singleRecord.Coverage.coveredLines);
                unCovered.put(singleRecord.ApexClassOrTrigger.Name, singleRecord.Coverage.uncoveredLines);
            }
        }
        for(String eachName : classNameList){
            Set<Integer> tempCovered = new Set<Integer>(covered.get(eachName));
            Set<Integer> tempUncovered = new Set<Integer>(unCovered.get(eachName));
            Set<Integer> totalLines = new Set<Integer>();
            totalLines.addAll(tempCovered);
            totalLines.addAll(tempUncovered);
            percetageCoverageMap.put(eachName, ((Decimal.valueOf(tempCovered.size())/Decimal.valueOf(totalLines.size()))*100).setScale(2));
        }
        return percetageCoverageMap;
    }
}