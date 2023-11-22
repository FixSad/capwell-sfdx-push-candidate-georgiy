@IsTest
public class MarketControllerTest {

    private static final String MARKET_LIST_NAME = 'Test Market List';

    @TestSetup
	private static void setup() {
        TestDataFactory.TestData data = TestDataFactory.generateData();
        Market_List__c marketList = new Market_List__c(Name = MARKET_LIST_NAME );
        insert marketList;
        insert new Market_List_Account__c(
            Account__c = data.acc.Id,
            Market_List__c = marketList.Id
        );
    } 
    
    @IsTest
    static void testGetMarkets() {
        Market_List__c marketList = [SELECT Name FROM Market_List__c WHERE Name =: MARKET_LIST_NAME LIMIT 1];
        Test.startTest();
        List<Market_List__c> result = MarketController.getMarkets();
        Test.stopTest();
        System.assertNotEquals(null, result);                                                                 
        System.assertEquals(1, result.size());  
        System.assertEquals(marketList.Name, result[0].Name);  
    }
    
    @IsTest
    static void testGetAssociatedMarkets01() {
        Account acc = [SELECT Name FROM Account LIMIT 1];
        Market_List__c marketList = [SELECT Name FROM Market_List__c WHERE Name =: MARKET_LIST_NAME LIMIT 1];
        Test.startTest();
        List<Market_List_Account__c> result = MarketController.getAssociatedMarkets(acc.Id);
        Test.stopTest();
        System.assertNotEquals(null, result);                                                                 
        System.assertEquals(1, result.size());  
        System.assertEquals(marketList.Id, result[0].Market_List__c);  
    }
    
    @IsTest
    static void testGetAssociatedMarkets02() {
        Test.startTest();
        List<Market_List_Account__c> result = MarketController.getAssociatedMarkets(null);
        Test.stopTest();
        System.assertEquals(null, result);        
    }      

    @IsTest
    static void testRemoveAssociation() {
        Market_List_Account__c marketListAcc = [SELECT Id FROM Market_List_Account__c LIMIT 1];
        Test.startTest();
        MarketController.removeAssociation(marketListAcc.Id);
        Test.stopTest();
        List<Market_List_Account__c> result = [SELECT Id FROM Market_List_Account__c];
        System.assertEquals(0, result.size());  
    }                                                   
    
}