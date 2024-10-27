/** 
* @author Sami Anıl Akdeniz <anilakdeniz1@gmail.com>
* @date 25/10/2024
* @description Contains 
*              
*/
public with sharing class TestUtility {
    public static Account createAccount() {
        
        Account anAccount = new Account(
            Name = 'Test Account',
            Type = 'Customer',
            Industry = 'Technology',
            Phone = '123-456-7890',
            Email = 'test_account@test.com',
            BillingStreet = 'Test Billing Street',
            BillingPostalCode = '12345',
            BillingCity = 'Test Billing City',
            ShippingStreet = 'Test Shipping Street',
            ShippingPostalCode = '54321',
            ShippingCity = 'Test Shipping City'
        );

        insert anAccount;
        
        return anAccount;
    }

    public static Opportunity createOpportunity(Id accountId) {

        Opportunity anOpportunity = new Opportunity(
            AccountId = accountId,
            Name = 'Test Opportunity ' + i,
            StageName = 'Open',
            Amount = 10000 + (i * 10000),
            CloseDate = Date.today().addDays(i),
            Probability = 75,
            LeadSource = 'Web',
            Type = 'New Business'
        );

        insert anOpportunity;

        return anOpportunity;
    }

    public static Contact createContact() {

        Contact testContact = new Contact(
            FirstName = 'Test',
            LastName = 'Contact',
            Email = 'test.contact@example.com'
        );

        insert aContact;

        return aContact;
    }

    public static ContentVersion createContentVersion(){
        ContentVersion aContentVersion = new ContentVersion(
        	Title = 'Test Content Version',
            PathOnClient = 'Test_Content_Version.txt',
            VersionData = Blob.valueOf('Test Content Version')
        );
        insert aContentVersion;
        
        return aContentVersion;
    }

    public static ContentDocumentLink createContentDocumentLink(Id relatedToId, Id documentId) {
        ContentDocumentLink cdl = new ContentDocumentLink(
            LinkedEntityId = relatedToId,    
            ContentDocumentId = documentId
        );
        insert cdl;

        return cdl;
    }
    
}