<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Number of LOP Users by RM</label>
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
        <value xsi:type="xsd:string">Count</value>
    </values>
    <values>
        <field>dlrs__AggregateResultField__c</field>
        <value xsi:type="xsd:string">Number_of_Sales_People_on_Portal__c</value>
    </values>
    <values>
        <field>dlrs__CalculationMode__c</field>
        <value xsi:type="xsd:string">Scheduled</value>
    </values>
    <values>
        <field>dlrs__CalculationSharingMode__c</field>
        <value xsi:type="xsd:string">User</value>
    </values>
    <values>
        <field>dlrs__ChildObject__c</field>
        <value xsi:type="xsd:string">Contact</value>
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
        <value xsi:type="xsd:string">Id</value>
    </values>
    <values>
        <field>dlrs__FieldToOrderBy__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>dlrs__ParentObject__c</field>
        <value xsi:type="xsd:string">User</value>
    </values>
    <values>
        <field>dlrs__RelationshipCriteriaFields__c</field>
        <value xsi:type="xsd:string">Contact_Role__c
HB_Signed__c
HO_Signed__c</value>
    </values>
    <values>
        <field>dlrs__RelationshipCriteria__c</field>
        <value xsi:type="xsd:string">Contact_Role__c in (&apos;Loan Officer&apos;, &apos;Agent&apos;, &apos;Broker/Owner&apos;, &apos;Loan Officer - Reverse&apos;) AND (HB_Signed__c = TRUE OR HO_Signed__c = TRUE)</value>
    </values>
    <values>
        <field>dlrs__RelationshipField__c</field>
        <value xsi:type="xsd:string">Sales_Director__c</value>
    </values>
    <values>
        <field>dlrs__RowLimit__c</field>
        <value xsi:nil="true"/>
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
