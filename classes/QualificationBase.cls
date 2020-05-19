public virtual class QualificationBase {
    
    public string Product { get; set; }
    public string MortgageType { get; set; }
    public PassbookRestHelper.passbookResponse passbookResponse;    
    public boolean passbookUsed {get; set; }
    public string passbookResult {get; set;}    
    
    public List<SelectOption> MortgageTypes {
        get {
            List<SelectOption> toReturn = new List<SelectOption>();
            toReturn.add(new SelectOption('Amortizing', 'Amortizing'));
            toReturn.add(new SelectOption('Interest Only', 'Interest Only'));
            toReturn.add(new SelectOption('Reverse Mortgage', 'Reverse Mortgage'));
            return toReturn;
        }
    }
    
    public decimal LTV { get; set; }
    public decimal FICO { get; set; }
    public decimal DTI { get; set; }
    public boolean passBookResults{ get; set; }

    public boolean calculated { get; set; }
    
    public string ResultT1 { get; set; }
    public string ResultT2 { get; set; }
    public string OverallResult {
        get {
            if (ResultT1 == 'Yes' && ResultT2 == 'Yes')
                return 'Pass';
            if (ResultT1 == 'No' || ResultT2 == 'No')
                return 'Fail';
            return 'Exception';
        }
    }
    
    public boolean CreateException { get; set; }
    public boolean showOptyButton { get; set; }
    public string ExceptionType { get; set; }
    
    public string MitigatingCircumstances { get; set; }
    
    public void Calculate() {
        calculated = true;
        
        string recType = '';
        if (Product == 'HomeOwner') {
            if (MortgageType == 'Amortizing') {
                recType = 'HO';
            }
            if (MortgageType == 'Interest Only' || MortgageType == 'Reverse Mortgage') {
                recType = 'HO IO';
            }
        }
        if (Product == 'New HomeOwner') {
            if (MortgageType == 'Amortizing') {
                recType = 'NHO';
            }
            if (MortgageType == 'Interest Only' || MortgageType == 'Reverse Mortgage') {
                recType = 'NHO IO';
            }
        }
        
        List<Exception_Fico_Guideline__c> ficoList = [SELECT Status__c FROM Exception_Fico_Guideline__c WHERE FICO__c <= :FICO AND LTV__c <= :LTV AND Type__c = :recType ORDER BY FICO__c DESC, LTV__c DESC LIMIT 1];
        List<Exception_DTI_Guideline__c> dtiList = [SELECT Status__c FROM Exception_DTI_Guideline__c WHERE DTI__c >= :DTI AND LTV__c <= :LTV AND Type__c = :recType ORDER BY DTI__c ASC, LTV__c DESC LIMIT 1];
        
        if (ficoList.size() > 0) {
            ResultT1 = ficoList[0].Status__c;
        }
         
        if (dtiList.size() > 0) {
            ResultT2 = dtiList[0].Status__c;
        }
        
        CreateException = false;
        if (OverallResult == 'Exception' || (OverallResult == 'Pass' && MortgageType == 'Reverse Mortgage')) {
            CreateException = true;
            ExceptionType = 'DTI;Mid FICO';
        }
        else
        {
            showOptyButton = true;
        }
        System.debug('====CreateException====='+CreateException);
        System.debug('=====showOptyButton===='+showOptyButton);
    }
    
    public LayoutWrapper caseLayout { get; set; }
    public Case newCase { get; set; }
    
    public PageReference SaveCase() {
        Savepoint sp = Database.setSavepoint();
        try {
            insert newCase;
            return new PageReference('/' + newCase.Id);
        } catch (Exception ex) {
            Database.rollback(sp);
            ApexPages.addMessages(ex);
            return null;
        }
    }
    
    public Metadata.UiBehavior MetadataUiBehaviorRequired {
        get {
            return Metadata.UiBehavior.Required;
        }
    }
    
    public class LayoutWrapper {
        public Metadata.Layout layout { get; set; }
        public List<SectionWrapper> sections { get; set; }
        
        public LayoutWrapper(Metadata.Layout layout) {
            this.layout = layout;
            sections = new List<SectionWrapper>();
            for (Metadata.LayoutSection section : layout.layoutSections) {
                if (section.style != Metadata.LayoutSectionStyle.CustomLinks) {
                  sections.add(new SectionWrapper(section));
                }
            }
        }
    }
    
    public class SectionWrapper {
        public Metadata.LayoutSection section { get; set; }
        public integer columns {
            get {
                if (section == null || section.style == Metadata.LayoutSectionStyle.TwoColumnsTopToBottom || section.style == Metadata.LayoutSectionStyle.TwoColumnsLeftToRight) {
                    return 2;
                } else {
                    return 1;
                }
            }
        }
        public List<Metadata.LayoutItem> fields { get; set; }
        
        public SectionWrapper(Metadata.LayoutSection section) {
            this.section = section;
            fields = new List<Metadata.LayoutItem>();
            integer fieldCnt = 0;
            
            boolean fieldFound = true;
            while (fieldFound) {
                fieldFound = false;
                for (Metadata.LayoutColumn column : section.layoutColumns) {
                    if (column.layoutItems != null && fieldCnt < column.layoutItems.size()) {
                        fieldFound = true;
                        fields.add(column.layoutItems[fieldCnt]);
                    }
                }
                fieldCnt++;
            }
        }
    }
}