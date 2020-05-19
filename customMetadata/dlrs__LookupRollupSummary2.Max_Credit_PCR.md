<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Max Credit Score PCR</label>
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
        <value xsi:type="xsd:string">First</value>
    </values>
    <values>
        <field>dlrs__AggregateResultField__c</field>
        <value xsi:type="xsd:string">Max_Credit_Score_PCR__c</value>
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
        <value xsi:type="xsd:string">LASERCA__Personal_Credit_Report__c</value>
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
        <value xsi:type="xsd:string">CreatedDate DESC</value>
    </values>
    <values>
        <field>dlrs__ParentObject__c</field>
        <value xsi:type="xsd:string">Lead</value>
    </values>
    <values>
        <field>dlrs__RelationshipCriteriaFields__c</field>
        <value xsi:type="xsd:string">LASERCA__Credit_Score_Median__c</value>
    </values>
    <values>
        <field>dlrs__RelationshipCriteria__c</field>
        <value xsi:type="xsd:string">LASERCA__Credit_Score_Median__c != 10000</value>
    </values>
    <values>
        <field>dlrs__RelationshipField__c</field>
        <value xsi:type="xsd:string">LASERCA__Lead__c</value>
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
