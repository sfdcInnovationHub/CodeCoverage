public class CodeCoverageWrapperClass {
    
	public String TestClassName{ get; set;}
    public String ClassName{ get; set;}
    public Set<Integer> CoveredLines{ get; set;}
    public Set<Integer> UncoveredLines{ get; set; }
    public Decimal PercentageCodeCoverage{ get; set; }
    
    public CodeCoverageWrapperClass(String testClassName, String className, Set<Integer> coveredLines, Set<Integer> uncoveredLines){
        this.TestClassName = testClassName;
        this.ClassName = className;
        this.CoveredLines = coveredLines;
        this.UncoveredLines = uncoveredLines;
        this.PercentageCodeCoverage = ((Decimal.valueOf(CoveredLines.size())/Decimal.valueOf(CoveredLines.size() + UncoveredLines.size()))*100).setScale(2);
    }
}