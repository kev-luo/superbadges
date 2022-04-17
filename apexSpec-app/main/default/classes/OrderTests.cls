@isTest(seeAllData=false)
private class OrderTests {
  @testSetup
  static void SetupTestData() {
    TestDataFactory.InsertTestData(3);
  }

  @isTest
  static void OrderUpdate_UnitTest() {
    Map<Id, Product2> testProductsMap = new Map<Id, Product2>();
    for (Product2 p : [SELECT Id, Quantity_Ordered__c FROM Product2]) {
      testProductsMap.put(p.Id, p);
    }

    List<Order> testOrders = [SELECT Id FROM Order];
    for (Order o : testOrders) {
      o.Status = Constants.ACTIVATED_ORDER_STATUS;
    }
    update testOrders;

    for (Product2 p : [SELECT Id, Quantity_Ordered__c FROM Product2]) {
      Product2 originalProduct = testProductsMap.get(p.Id);
      Product2 updatedProduct = p;

      System.assertEquals(
        true,
        TestDataFactory.VerifyQuantityOrdered(
          originalProduct,
          updatedProduct,
          Constants.DEFAULT_ROWS
        )
      );
    }
  }
}
