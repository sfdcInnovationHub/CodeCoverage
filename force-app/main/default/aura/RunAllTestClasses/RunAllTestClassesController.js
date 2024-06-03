({
    fetchTestClasses : function(component, event, helper){
        component.set('v.columns',[
            {label: 'Test Class Name', fieldName: 'Name', type: 'text'},
            {label: 'Status', fieldName: 'Status', type: 'text'},
            {label: 'Created Date', fieldName: 'CreatedDate', type: 'text'}
        ]);
        var action = component.get('c.getTestClasses');
        action.setParams({});
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state==='SUCCESS'){
                var result = response.getReturnValue();
                console.log(result);
            }
            component.set('v.displayTestClasses', result);
        });
        $A.enqueueAction(action);
    },
    
    handleKeyUp : function(component, event, helper){
        var showList = component.get('v.showList');                 //This list shows the final values selected
        var permList = component.get('v.permanentList');            //This list shows the values selected by the user before entering the search term
        var tempList = component.get('v.temporaryList');            //This is the temporary list which has been selected by the user recently.

        var searchKeyWord = component.find("enterSearch").get("v.value");
        //When user enters a search word
        if(searchKeyWord.length != 0){
            component.set('v.inSearch' , true);	
        }
        //When the search bar is not empty
        else if(searchKeyWord.length == 0){
            console.log("search length is zero");
            component.set('v.inSearch', false);
            var permSet = new Set();
            var showSet = new Set();                                //This set holds the values from the list that are to be displayed.

            for(var each in permList){
                permSet.add(permList[each]);                          
            }
            for (var each in showList){
                showSet.add(showList[each]);
            }

            for(var each of permSet){
                showSet.add(each);
            }
            showList = Array.from(showSet);           
        }
        var action = component.get("c.fetchRecords");
        action.setParams({searchWord : searchKeyWord})
        action.setCallback(this, function(response){
            var state=response.getState();
            var result = response.getReturnValue();
            if(state==='SUCCESS'){
                component.set('v.showList', showList);
                component.set("v.displayTestClasses",result);
            }
        });
        $A.enqueueAction(action);
    },
    
    storeData : function(component, event, helper){        
        var selectedRowData = event.getParam('selectedRows');            //The selected row data has been fetched from the aura component.       
        var tempList = [];
        for(var eachRecord in selectedRowData){
            tempList.push(selectedRowData[eachRecord].Id);
        }
        component.set('v.temporaryList', tempList);
        var showList = component.get('v.showList');
        var permList = component.get('v.permanentList');
        var tempList = component.get('v.temporaryList');
        var inSearch = component.get('v.inSearch');
        if(inSearch == false){
			component.set('v.showList', tempList);
        }
        // When inSearch is true
        else{
            var data = component.get('v.displayTestClasses');
            var showList = component.get('v.showList');
            console.log('data', data);
            var dataList = [];
            for(var each in data){
                dataList.push(data[each].Id);
            }
            var showSet = new Set();
            var dataSet = new Set();
            var tempSet = new Set();
            
            for (var each in showList){
                showSet.add(showList[each]);
            }
            for (var each in dataList){
                dataSet.add(dataList[each]);
            }
            for(var each in tempList){
                tempSet.add(tempList[each]);
            }
            
            for(var each of tempSet){
                showSet.add(each);
            }
			            
            for(var each of tempSet){
                dataSet.delete(each);
            }
            //Now dataSet contains those value which are not selected.
            
            for(var each of dataSet){
                showSet.delete(each);
            }
            
            showList = Array.from(showSet);
            component.set('v.showList', showList);
        }
    },
    
    submitSelected : function(component, event, helper){
        var selectedRows = component.get('v.showList');
        component.set('v.selectedRowsNumber', selectedRows.length);         //The data of number of selected Rows are stored over here.
        var action = component.get('c.runSelected');
        action.setParams({testClassesId : selectedRows});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if (state==='SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.asyncJob', result);                        //The AsyncJob Id has been stored in the aura component.
            }
            
        });
		$A.enqueueAction(action);
        component.set('v.showButton2', true);
    },
    
	runAllTestClasses : function(component, event, helper) {                      //When the run all test classes button is clicked.
		var action = component.get('c.runAll');
        action.setParams({});
        action.setCallback(this, function(response){                        
            var state = response.getState();
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();
                for(var each in result){
                    component.set('v.asyncJob', each);
                    component.set('v.selectedRowsNumber', result[each]);        //Total number of test classes that ran are counted here.
                }                
            }
        });
        $A.enqueueAction(action);
        component.set('v.showButton2', true);
    },
    
    testClassesResults : function(component, event, helper){
        var numberOfSelectedRows = component.get('v.selectedRowsNumber');
        var asyncJobId = component.get('v.asyncJob');
    	var action= component.get('c.checkStatus');
        action.setParams({currentId : asyncJobId});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state=='SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.testResultData', result);

                //Toast message if all the test classes that have been queued have not completed running.
                if(result.length < numberOfSelectedRows){
            		var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        type: 'warning',
                        title: 'Warning!',
                        message: 'Some test cases are running in background! \n Please click on check status again to refresh!'
                    });
                    toastEvent.fire();
            	}
                //Toast message if all the test classes that have been queued have completed running.
                else if(result.length ==  numberOfSelectedRows){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'dismissible',
                        type: 'success',
                        duration: '2',
                        title: 'Success!',
                        message: 'All test classes have run successfully!'
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);        
        component.set('v.checkStatus', true);
        component.set('v.showButton3', true);
    },

    //API callout to get the coverage by the test classes for each of their respective classes.
    apiCallout : function(component, event, helper){
        var testResultData = component.get('v.testResultData');
        var testClassesName = [];
        for(var each in testResultData){
            testClassesName.push(testResultData[each].ApexClass.Name);
        }
        var action = component.get('c.getCodeCoverageForEachTest');
        action.setParams({testClasses: testClassesName});
        action.setCallback(this, function(response){
            var state = response.getState();
            var resultData = [];
            var classNameSet = new Set();
            if(state==='SUCCESS'){
                var result = response.getReturnValue();
                for(var each in result){
                    resultData.push(JSON.parse(result[each]));
                }
                for(var i in resultData){
                    classNameSet.add(resultData[i].ClassName);
                    
                }
                var classNames = Array.from(classNameSet);
                component.set('v.classNameList', classNames);
                component.set('v.coverageColumns',[
                    {label: 'Test Class Name', fieldName: 'TestClassName', type: 'text'},
                    {label: 'Class Name', fieldName: 'ClassName', type: 'text'},
                    {label: 'Percentage Code Coverage', fieldName: 'PercentageCodeCoverage', type: 'text'}
                ]);
                component.set('v.responseData', resultData);
            }
        });
        $A.enqueueAction(action);
        component.set('v.checkCodeCoverage', true);
        component.set('v.showCoverageClassButton', true);
    },
    
    //API callout for getting the org code coverage of the classes that have been checked with the test classes.
    codeCoverageForClass : function(component, event, helper){
        var classNames = component.get('v.classNameList');
        var feedingData = [];
        var action = component.get('c.codeCoverageEachClass');
        action.setParams({classNameList : classNames});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                for(var each in result){
                    feedingData.push({key: each, value: result[each]});
                }
            }
            console.log(feedingData);
            component.set('v.coverageEachClass', feedingData);
            component.set('v.checkCodeCoverageEachClass', true);
        });
        $A.enqueueAction(action);
    }, 
    
    //Downloading the details in CSV format for the test classes
    downlaodDataEachTestClass : function(component, event, helper){
        var listData = component.get("v.responseData"); 
        console.log('In download Data');
        var csv = helper.convertToCSVEachTestClass(component,listData); 
       
        if (csv == null){
            return;
        }
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'CodeCoverage_EachTestClass.csv';
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    },
    
    //Downloading the details in CSV format for the classes that have been tested by the selected test classes
    downloadDataEachClass : function(component, event, helper){
        var listData = component.get("v.coverageEachClass"); 
        var csv = helper.convertToCSVEachClass(component,listData); 
        if (csv == null){
            return;
        }
        // ####--code for create a temp. <a> html tag [link tag] for download the CSV file--####     
        var hiddenElement = document.createElement('a');
        hiddenElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        hiddenElement.target = '_self'; // 
        hiddenElement.download = 'CodeCoverage_EachInvolvedClass.csv';
        document.body.appendChild(hiddenElement); // Required for FireFox browser
        hiddenElement.click(); // using click() js function to download csv file
    }
})