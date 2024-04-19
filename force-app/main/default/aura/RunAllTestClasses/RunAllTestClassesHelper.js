({
	convertToCSVEachTestClass : function(component, objectRecords) {
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        console.log('In helper');
        columnDivider = ',';
        lineDivider =  '\n'; 
        keys = ['TestClassName', 'ClassName', 'PercentageCodeCoverage'];
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        
        for(var i=0; i < objectRecords.length; i++){   
            counter = 0;
            
            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;
                if(counter > 0){ 
                    csvStringResult += columnDivider; 
                }
                              
                csvStringResult += '"'+ objectRecords[i][skey]+'"'; 
                
                counter++;
            }
            csvStringResult += lineDivider;
        } 
        return csvStringResult;        
	},
    
    	convertToCSVEachClass : function(component, objectRecords) {
        var csvStringResult, counter, keys, columnDivider, lineDivider;
        if (objectRecords == null || !objectRecords.length) {
            return null;
        }
        columnDivider = ',';
        lineDivider =  '\n'; 
        keys = ['ClassName', 'PercentageCodeCoverage'];
        csvStringResult = '';
        csvStringResult += keys.join(columnDivider);
        csvStringResult += lineDivider;
        for(var i=0; i < objectRecords.length; i++){   
            csvStringResult += '"'+ objectRecords[i].key+'"';
            csvStringResult += columnDivider;
            csvStringResult += '"'+ objectRecords[i].value+'"';
            csvStringResult += lineDivider;
        } 
        return csvStringResult;        
	}
    
})