<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Opportunity - Purchase_Price__c</label>
    <protected>false</protected>
    <values>
        <field>Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Additional_Fields__c</field>
        <value xsi:nil="true"/>
    </values>
    <values>
        <field>Conditions__c</field>
        <value xsi:type="xsd:string">RecordType == &apos;HomeBuyer&apos; OR RecordType == &apos;HomeBuyer_Canada&apos;</value>
    </values>
    <values>
        <field>Description__c</field>
        <value xsi:type="xsd:string">Purchase Price must be populated (HB)</value>
    </values>
    <values>
        <field>Field_API_Name__c</field>
        <value xsi:type="xsd:string">Purchase_Price__c</value>
    </values>
    <values>
        <field>Locked_By_Stage__c</field>
        <value xsi:type="xsd:string">Final Approval</value>
    </values>
    <values>
        <field>Object__c</field>
        <value xsi:type="xsd:string">Opportunity</value>
    </values>
    <values>
        <field>Populated_By_Stage__c</field>
        <value xsi:type="xsd:string">Investment Due Diligence</value>
    </values>
    <values>
        <field>Validation__c</field>
        <value xsi:type="xsd:string">Purchase_Price__c != NULL AND Purchase_Price__c &gt; 0</value>
    </values>
</CustomMetadata>
