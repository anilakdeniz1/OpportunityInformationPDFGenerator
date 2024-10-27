/** 
* @author Sami Anıl Akdeniz <anilakdeniz1@gmail.com>
* @date 25/10/2024
* @description Test class for pdfGeneratorController
*/
public with sharing class pdfGeneratorControllerTest {
    
    @TestSetup
    static void makeData(){
        
        Account anAccount = TestUtility.createAccount();

        Opportunity anOpportunity = TestUtility.createOpportunity(anAccountId);

    }

    @isTest
    static void loadData_successfully() {
        
        Opportunity anOpportunity = [SELECT Id FROM Opportunity LIMIT 1];

        ApexPages.StandardController aStandardController = new ApexPages.StandardController(anOpportunity);
        PdfGeneratorController controller = new PdfGeneratorController(aStandardController);

        Test.startTest();
            
        Opportunity aLoadedOpportunity = controller.opportunity;

        Test.stopTest();

        System.AssertNotEquals(null, aLoadedOpportunity, 'Opportunity should not be null.');
        System.AssertEquals(anOpportunity.Id, aLoadedOpportunity.Id, 'Opportunity ID should match the test record.');
        System.AssertNotEquals(null, anlagenpassController.todayDate, 'Today\'s date should not be null.');
    }

    @isTest
    static void doNotloadData_whenOpportunityIdIsNull() {

        ApexPages.StandardController aStandardController = new ApexPages.StandardController(new Opportunity());

        Test.startTest();
        
        PdfGeneratorController controller = new PdfGeneratorController(aStandardController);
        
        Test.stopTest();

        Opportunity anOpportunity = controller.opportunity;
        
        System.assertEquals(null, anOpportunity , 'Data should not be created.');
    }

    @isTest
    static void savePDFOnOpportunity_whenPDFIsGenerated(){
        
        Opportunity anOpportunity = [SELECT Id FROM Opportunity LIMIT 1];    
              
        Test.startTest();
        
        PdfGeneratorController.saveOpportunityPDF(anOpportunity.Id);
        
        Test.stopTest();

        List<ContentDocumentLink> aContentDocumentLink = [SELECT Id, ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :anOpportunity.Id];

        List<ContentVersion> aContentVersion = [SELECT Id, Title, VersionData FROM ContentVersion WHERE ContentDocumentId = :aContentDocumentLink[0].ContentDocumentId];

        System.AssertEquals(1, aContentDocumentLink.size(), 'Content Document Link should be created.');

        Assert.areEqual('OpportunityInfo', aContentVersion[0].title, 'Content versions\'s name should be "OpportunityInfo".');
        
    }

    @isTest
    static void sendEmail_handleOpportunityStageChange() {

        Opportunity anOpportunity = [SELECT Id, Primary_Contact__c FROM Opportunity LIMIT 1]; 

        ContentVersion aContentVersion = TestUtility.createContentVersion();

        ContentDocument aContentDocument = [SELECT Id FROM ContentDocument WHERE LatestPublishedVersionId = :aContentVersion.Id]; 

        ContentDocumentLink aContentDocumentLink = TestUtility.createContentDocumentLink(aContentDocument.Id, anOpportunity.Id);
        
        Test.startTest();

        PdfGeneratorController.sendPDFViaEmail(anOpportunity.Id, anOpportunity.Primary_Contact__c);

        Test.stopTest();

        System.AssertEquals(1, AnlagenpassController.anlagenpassEmailsToSend.size(), 'anlagenpassEmailsToSend\'s size should be 1.');

    }
}