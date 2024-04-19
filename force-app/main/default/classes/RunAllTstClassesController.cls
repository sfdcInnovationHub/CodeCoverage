public class RunAllTstClassesController {
    @AuraEnabled
    public static List<ApexClass> getTestClasses(){
        List<ApexClass> testClasses = new List<ApexClass>([SELECT Id, Name, Status, CreatedDate FROM ApexClass WHERE Name LIKE '%Test%' LIMIT 10]);
        return testClasses;
    }
    
    @AuraEnabled
    public static List<ApexClass> fetchRecords(String searchWord){
        String modifiedKeyWord =  searchWord + '%Test%';
        List<ApexClass> fetchedList = new List<ApexClass> ([ SELECT Id, Name, Status, CreatedDate FROM ApexClass WHERE Name LIKE :modifiedKeyWord]);
        return fetchedList;
    }
    
    @AuraEnabled
    public static Id runSelected(List<Id> testClassesId){
        List<ApexTestQueueItem> testQueueItems = new List<ApexTestQueueItem>();
        for(Id eachRecord : testClassesId){
            ApexTestQueueItem testQueueItem = new ApexTestQueueItem();
            testQueueItem.ApexClassId = eachRecord;
            testQueueItems.add(testQueueItem);
        }
        insert testQueueItems;
        ApexTestQueueItem item = [SELECT ParentJobId FROM ApexTestQueueItem WHERE Id =: testQueueItems[0].Id LIMIT 1];
        return item.ParentJobId;
    }
    
	@AuraEnabled  
    public static Map<Id, Integer> getHandler(){
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
        insert testQueueItems;
        Id tempId = testQueueItems[0].Id;
        ApexTestQueueItem temp = new ApexTestQueueItem();
        temp = [SELECT ParentJobId FROM ApexTestQueueItem WHERE Id =: tempId LIMIT 1];
        Map<Id, Integer> returnMap = new Map<Id, Integer>();
        returnMap.put(temp.ParentJobId, numberOfTestClasses);
        return returnMap;
        
        
        /*
        RunAllTstClassesBatch variable = new RunAllTstClassesBatch();
        Id apexJobId = Database.executeBatch(variable, 2);
        System.debug('Successfull');
        //AsyncApexJob batchApexWorker = [SELECT CompletedDate]
        return apexJobId;*/
    }
    @AuraEnabled
    public static List<ApexTestResult> checkStatus(Id currentId){
        System.debug('In checkStatus');
        system.debug(currentId);
        AsyncApexJob testRequestJobStatus = new AsyncApexJob();
        testRequestJobStatus = [SELECT  Status FROM AsyncApexJob WHERE Id =: currentId LIMIT 1];
        List<ApexTestQueueItem> testClassesStatus = new List<ApexTestQueueItem>([SELECT Status FROM ApexTestQueueItem WHERE ParentJobId =: currentId]);
        List<ApexTestResult> testResults = new List<ApexTestResult>();
        for(ApexTestQueueItem record : testClassesStatus){
            if(record.Status == 'Completed'){
                testResults = [SELECT ApexClass.Name, Outcome, MethodName, Message, StackTrace, SystemModstamp FROM ApexTestResult WHERE AsyncApexJobId =: currentId];
            }
            else{
               return testResults;
            }
        }
        return testResults;
    }
    @AuraEnabled
    public static List<String> getApexCodeCoverage(List<String> testClasses){
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
        System.debug('getApexCodeCoverage called');
        System.debug(testClasses);        
        Http newReq = new Http();
        HttpRequest hreq = new HttpRequest();
        hreq.setHeader('Content-Type', 'application/json');
        hreq.setEndpoint(endpoint);
        hreq.setMethod('GET');
        HttpResponse hresp = NewReq.send(hreq);
        String body = hresp.getBody();
        System.debug('ResponseBody' + body);
        JsonApexCodeCoverage bodyResult = JsonApexCodeCoverage.parse(body);
        
        List<String> data = new List<String>();
        for(String test : testClasses){
        	for(JsonApexCodeCoverage.Records singleRecord : bodyresult.Records){
                if(singleRecord.ApexTestClass.Name == test){
                    CodeCoverageWrapperClass newInstance = new CodeCoverageWrapperClass(test, singleRecord.ApexClassOrTrigger.Name, singleRecord.Coverage.coveredLines, singleRecord.Coverage.uncoveredLines);
                    data.add(JSON.serialize(newInstance));
                }
            }
        }
        System.debug(data);
        return data;
    }
    
    @AuraEnabled
    public static Map<String, Decimal> CodeCoverageEachClass(List<String> classNameList){
       System.debug(classNameList);
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