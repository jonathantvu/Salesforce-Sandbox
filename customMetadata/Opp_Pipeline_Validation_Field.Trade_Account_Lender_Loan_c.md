<?xml version="1.0" encoding="UTF-8"?>
<CustomMetadata xmlns="http://soap.sforce.com/2006/04/metadata" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <label>Trade Account - Lender_Loan__c</label>
    <protected>false</protected>
    <values>
        <field>Active__c</field>
        <value xsi:type="xsd:boolean">true</value>
    </values>
    <values>
        <field>Additional_Fields__c</field>
        <value xsi:type="xsd:string">Credit_Loan_Type_pick__c</value>
    </values>
    <values>
        <field>Conditions__c</field>
        <value xsi:type="xsd:string">Credit_Loan_Type_pick__c == &apos;Mortgage&apos; AND Exclude__c == FALSE</value>
    </values>
    <values>
        <field>Description__c</field>
        <value xsi:type="xsd:string">Mortgage loan number must be populated</value>
    </values>
    <values>
        <field>Field_API_Name__c</field>
        <value xsi:type="xsd:string">Lender_Loan__c</value>
    </values>
    <values>
        <field>Locked_By_Stage__c</field>
        <value xsi:type="xsd:string">Final Approval</value>
    </values>
    <values>
        <field>Object__c</field>
        <value xsi:type="xsd:string">Trade Account</value>
    </values>
    <values>
        <field>Populated_By_Stage__c</field>
        <value xsi:type="xsd:string">Investment Due Diligence</value>
    </values>
    <values>
        <field>Validation__c</field>
        <value xsi:type="xsd:string">Lender_Loan__c != NULL</value>
    </values>
</CustomMetadata>
