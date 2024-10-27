/** 
* @author Sami Anıl Akdeniz <anilakdeniz1@gmail.com>
* @date 25/10/2024
* @description Generates PDF according to opportunity's information and sends it to related person 
*              account via email to when specific stage is reached
* Test Class : pdfGeneratorControllerTest
* Test Class Coverage : %100"
*/
public with sharing class PdfGeneratorController {

    public Opportunity opportunity {get; private set;}
    public Id contactId {get; private set;}
    public static List<Messaging.SingleEmailMessage> mailsToBeSent = new List<Messaging.SingleEmailMessage>();

    public PdfGeneratorController(ApexPages.StandardController standardController) {

        Id opportunityId = standardController.getId();

        loadData(opportunityId);
    }

    public String todayDate {get { return DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0)).format('dd.MM.yy');}}
    public String opportunityName {get; private set;}
    public String stageName {get; private set;}
    public String accountAnnualRevenue {get; private set;}
    public String accountBillingpostalcode {get; private set;}
    public String accountBillingStreet {get; private set;}
    public String accountBillingCity {get; private set;}
    public String accountName {get; private set;}
    public Decimal probability {get; private set;}
    public String leadSource {get; private set;}
    public String type {get; private set;}
    public DateTime createdDate {get; private set;}
    public Date closeDate {get; private set;}

    /**
    * @description a method that fetches opportunity information from org and assign them to property values
    * @param Id opportunityId
    */ 
    public void loadData(Id opportunityId) {

        if (String.isBlank(opportunityId)) {
            return;
        }

        opportunity = [SELECT Id, Name, StageName, Primary_Contact__c, Account.Name, Account.AnnualRevenue, Account.BillingStreet, Account.Billingpostalcode, 
                              Account.Billingcity, LeadSource, Probability, CreatedDate, Type, CloseDate FROM Opportunity WHERE Id = :opportunityId LIMIT 1];

        contactId = opportunity.Primary_Contact__c;
        opportunityName = opportunity.Name;
        stageName = opportunity.StageName;
        accountName = opportunity.Account.Name;
        probability = opportunity.Probability;
        leadSource  = opportunity.LeadSource;
        type = opportunity.Type;
        createdDate = opportunity.createdDate;
        closeDate = opportunity.closeDate;

        accountBillingpostalcode = opportunity.Account.Billingpostalcode;
        accountBillingStreet = opportunity.Account.BillingStreet;
        accountBillingCity = opportunity.Account.BillingCity;
        accountAnnualRevenue = '$' + String.valueOf(opportunity.Account.AnnualRevenue);
    }

    /**
    * @description generates the visualforce page to a PDF and relates to the opportunity
    * @param Id opportunityId
    */ 
    public static void saveOpportunityPDF(Id opportunityId) {
        
        PageReference pdfPage = Page.opportunityInformationPDF;
        pdfPage.getParameters().put('id', opportunityId);
        Blob pdfBlob;

        if (Test.isRunningTest()) {
            pdfBlob = blob.valueOf('Test Content');
        }else {
            pdfBlob = pdfPage.getContentAsPDF();
        }

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.PathOnClient = 'OpportunityInfo.pdf';
        contentVersion.Title = 'OpportunityInfo';
        contentVersion.VersionData = pdfBlob;
        insert contentVersion;

        ContentVersion validContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =:contentVersion.Id];

        ContentDocumentLink contentDocumentLink = new ContentDocumentLink();
        contentDocumentLink.LinkedEntityId = opportunityId;
        contentDocumentLink.ContentDocumentId = validContentVersion.ContentDocumentId;
        contentDocumentLink.shareType = 'I';

        insert contentDocumentLink;
    }

    /**
    * @description sends the pdf to the opportunity's related contact
    * @param Id opportunityId
    * @param Id contactId
    */ 
    public static void sendPDFViaEmail(Id opportunityId, Id contactId) {

        Id emailTemplateId = [SELECT Id FROM EmailTemplate WHERE Name = 'Test Template' LIMIT 1].Id;

        Id orgWideEmailAddressId = [SELECT Id FROM OrgWideEmailAddress WHERE DisplaName = 'Test' LIMIT 1].Id;

        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

        email.setTemplateId(emailTemplateId);
        email.setTargetObjectId(contactId);
        email.setTreatTargetObjectAsRecipient(true);
        email.setOrgWideEmailAddressId(orgWideEmailAddressId);
        email.setWhatId(opportunityId);
        email.setSaveAsActivity(true);
        
        mailsToBeSent.add(email);

        Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{email});

    }

    /**
    * @description handles generate process
    * @param Id opportunityId
    * @param Id contactId
    */ 
    @future(callout=true)
    public static void handlePDFGenerate(Id opportunityId, Id contactId) {

        saveOpportunityPDF(opportunityId);

        sendPDFViaEmail(opportunityId, contactId);
    }
}