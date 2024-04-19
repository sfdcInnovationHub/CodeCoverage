public class JsonApexCodeCoverage {
	public class ApexClassOrTrigger {
		public Attributes attributes;
		public String Name;
	}
    public class ApexTestClass{
        public Attributes attributes;
        public String Name;
    }
	public Integer size;
	public Integer totalSize;
	public Boolean done;
	public Object queryLocator;
	public String entityTypeName;
	public List<Records> records;

	public class Attributes {
		public String type;
		public String url;
	}
	
    public class Coverage{
        public Set<Integer> coveredLines;
        public Set<Integer> uncoveredLines;
    }
	public class Records {
		public Attributes attributes;
		public Id Id;
		public ApexClassOrTrigger ApexClassOrTrigger;
        public ApexTestClass ApexTestClass;
        public Id ApexClassorTriggerId;
        public Coverage Coverage;
	}
    
	public static JsonApexCodeCoverage parse(String json) {
		return (JsonApexCodeCoverage) System.JSON.deserialize(json, JsonApexCodeCoverage.class);
	}
}