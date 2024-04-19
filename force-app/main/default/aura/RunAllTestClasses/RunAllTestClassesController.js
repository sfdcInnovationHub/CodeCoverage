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
        var showList = component.get('v.showList');
        var permList = component.get('v.permanentList');
        var tempList = component.get('v.temporaryList');
        
        console.log('line 26', showList);
        var searchKeyWord = component.find("enterSearch").get("v.value");
        if(searchKeyWord.length != 0){
            console.log(searchKeyWord, 'line 25');
            component.set('v.inSearch' , true);	
            console.log("length not zero");
        }
        else if(searchKeyWord.length == 0){
            console.log("search length is zero");
            component.set('v.inSearch', false);
            var permSet = new Set();
            var showSet = new Set();
            console.log("line 36");
            for(var each in permList){
                permSet.add(permList[each]);
            }
            for (var each in showList){
                showSet.add(showList[each]);
            }
            console.log('line 47', showSet);
            for(var each of permSet){
                showSet.add(each);
            }
            showList = Array.from(showSet);
            console.log('line 52', showList);           
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
        var selectedRowData = event.getParam('selectedRows');
        console.log('line 67', selectedRowData);
        var tempList = [];
        for(var eachRecord in selectedRowData){
            tempList.push(selectedRowData[eachRecord].Id);
        }
        console.log('line 75', tempList[0]);
        component.set('v.temporaryList', tempList);
        var showList = component.get('v.showList');
        var permList = component.get('v.permanentList');
        var tempList = component.get('v.temporaryList');
        var inSearch = component.get('v.inSearch');
        if(inSearch == false){
            console.log('in search false', inSearch);
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
                console.log('dataSet' , dataSet);
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
        component.set('v.selectedRowsNumber', selectedRows.length); //The data of number of selected Rows are stored over here.
        var action = component.get('c.runSelected');
        action.setParams({testClassesId : selectedRows});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if (state==='SUCCESS'){
                var result = response.getReturnValue();
                console.log(result);
                component.set('v.asyncJob', result);
            }
            
        });
		$A.enqueueAction(action);
        component.set('v.showButton2', true);
    },
    
	handleClick : function(component, event, helper) {
        console.log('In handleClick');
		var action = component.get('c.getHandler');
        action.setParams({});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if(state=='SUCCESS'){  
                var result = response.getReturnValue();
                console.log(result);
                for(var each in result){
                    component.set('v.asyncJob', each);
                    component.set('v.selectedRowsNumber', result[each]);
                }                
            }
        });
        $A.enqueueAction(action);
        component.set('v.showButton2', true);
    },
    
    testClassesResults : function(component, event, helper){
    	console.log('In testClassesResults');
        var numberOfSelectedRows = component.get('v.selectedRowsNumber');
        var asyncJobId = component.get('v.asyncJob');
        console.log(asyncJobId);
    	var action= component.get('c.checkStatus');
        action.setParams({currentId : asyncJobId});
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log(state);
            if(state=='SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.testResultData', result);
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
    
    apiCallout : function(component, event, helper){
        console.log('In apiCallout');
        var testResultData = component.get('v.testResultData');
        console.log(testResultData);
        var testClassesName = [];
        for(var each in testResultData){
            testClassesName.push(testResultData[each].ApexClass.Name);
        }
        var action = component.get('c.getApexCodeCoverage');
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
    
    codeCoverageForClass : function(component, event, helper){
        var classNames = component.get('v.classNameList');
        var feedingData = [];
        var action = component.get('c.CodeCoverageEachClass');
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