<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Application - Co_Applicant_Social_Securi</label>
    <protected>false</protected>
    <values>
        <field>Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Additional_Fields__c</field>
        <value xsi:type="xsd:string">Is_there_Co_App__c</value>
    </values>
    <values>
        <field>Conditions__c</field>
        <value xsi:type="xsd:string">Is_there_Co_App__c == true</value>
    </values>
    <values>
        <field>Description__c</field>
        <value xsi:type="xsd:string">Co-Applicant SSN must be populated</value>
    </values>
    <values>
        <field>Field_API_Name__c</field>
        <value xsi:type="xsd:string">Co_Applicant_Social_Security_Number__c</value>
    </values>
    <values>
        <field>Locked_By_Stage__c</field>
        <value xsi:type="xsd:string">Funded Won</value>
    </values>
    <values>
        <field>Object__c</field>
        <value xsi:type="xsd:string">Application</value>
    </values>
    <values>
        <field>Populated_By_Stage__c</field>
        <value xsi:type="xsd:string">Investment Due Diligence</value>
    </values>
    <values>
        <field>Validation__c</field>
        <value xsi:type="xsd:string">Co_Applicant_Social_Security_Number__c != NULL</value>
    </values>
</CustomMetadata>
