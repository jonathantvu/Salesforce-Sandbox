public with sharing class ContactInLineEdit {
    private Final Account acc;
    public ContactInLineEdit(ApexPages.StandardController stdController)
    {
        this.acc = (Account)stdcontroller.getRecord();
        lstContacts = [select id, firstname, lastname, email, phone from Contact where accountid =:this.acc.id];
        
    }
    public List<Contact> lstContacts{get;set;}
}