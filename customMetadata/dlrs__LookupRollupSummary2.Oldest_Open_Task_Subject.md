<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Oldest Open Task Subject</label>
    <protected>false</protected>
    <values>
        <field>dlrs__Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>dlrs__AggregateAllRows__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>dlrs__AggregateOperation__c</field>
        <value xsi:type="xsd:string">Concatenate</value>
    </values>
    <values>
        <field>dlrs__AggregateResultField__c</field>
        <value xsi:type="xsd:string">Oldest_Open_Task_Subject__c</value>
    </values>
    <values>
        <field>dlrs__CalculationMode__c</field>
        <value xsi:type="xsd:string">Realtime</value>
    </values>
    <values>
        <field>dlrs__CalculationSharingMode__c</field>
        <value xsi:type="xsd:string">System</value>
    </values>
    <values>
        <field>dlrs__ChildObject__c</field>
        <value xsi:type="xsd:string">Task</value>
    </values>
    <values>
        <field>dlrs__ConcatenateDelimiter__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>dlrs__Description__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>dlrs__FieldToAggregate__c</field>
        <value xsi:type="xsd:string">Subject</value>
    </values>
    <values>
        <field>dlrs__FieldToOrderBy__c</field>
        <value xsi:type="xsd:string">Due_Date_Hidden__c ASC</value>
    </values>
    <values>
        <field>dlrs__ParentObject__c</field>
        <value xsi:type="xsd:string">Lead</value>
    </values>
    <values>
        <field>dlrs__RelationshipCriteriaFields__c</field>
        <value xsi:type="xsd:string">Is_Closed__c</value>
    </values>
    <values>
        <field>dlrs__RelationshipCriteria__c</field>
        <value xsi:type="xsd:string">Is_Closed__c = FALSE</value>
    </values>
    <values>
        <field>dlrs__RelationshipField__c</field>
        <value xsi:type="xsd:string">WhoId</value>
    </values>
    <values>
        <field>dlrs__RowLimit__c</field>
        <value xsi:type="xsd:double">1.0</value>
    </values>
    <values>
        <field>dlrs__TestCodeSeeAllData__c</field>
        <value xsi:type="xsd:boolean">false</value>
    </values>
    <values>
        <field>dlrs__TestCode__c</field>
        <value xsi:nil="true"/>
    </values>
</CustomMetadata>
