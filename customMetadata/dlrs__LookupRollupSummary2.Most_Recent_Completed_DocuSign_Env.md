<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Most Recent Completed DocuSign Envelope</label>
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
        <value xsi:type="xsd:string">DocuSign_Completed_Date_Time__c</value>
    </values>
    <values>
        <field>dlrs__CalculationMode__c</field>
        <value xsi:type="xsd:string">Realtime</value>
    </values>
    <values>
        <field>dlrs__CalculationSharingMode__c</field>
        <value xsi:type="xsd:string">User</value>
    </values>
    <values>
        <field>dlrs__ChildObject__c</field>
        <value xsi:type="xsd:string">dsfs__DocuSign_Status__c</value>
    </values>
    <values>
        <field>dlrs__ConcatenateDelimiter__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>dlrs__Description__c</field>
        <value xsi:type="xsd:string">Populates the most recently completed DocuSign envelope complete time into the Lead</value>
    </values>
    <values>
        <field>dlrs__FieldToAggregate__c</field>
        <value xsi:type="xsd:string">dsfs__Completed_Date_Time__c</value>
    </values>
    <values>
        <field>dlrs__FieldToOrderBy__c</field>
        <value xsi:type="xsd:string">dsfs__Completed_Date_Time__c DESC NULLS LAST</value>
    </values>
    <values>
        <field>dlrs__ParentObject__c</field>
        <value xsi:type="xsd:string">Lead</value>
    </values>
    <values>
        <field>dlrs__RelationshipCriteriaFields__c</field>
        <value xsi:type="xsd:string">dsfs__Envelope_Status__c</value>
    </values>
    <values>
        <field>dlrs__RelationshipCriteria__c</field>
        <value xsi:type="xsd:string">dsfs__Envelope_Status__c = &apos;Completed&apos;</value>
    </values>
    <values>
        <field>dlrs__RelationshipField__c</field>
        <value xsi:type="xsd:string">dsfs__Lead__c</value>
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
