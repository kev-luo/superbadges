@isTest(seeAllData=true)
private class Product2Tests {
  /**
   * @name product2Extension_UnitTest
   * @description UnitTest for product2Extension
   **/
  static testMethod void Product2Extension_UnitTest() {
    PageReference pageRef = Page.Product2New;
    Product2 testProduct = new Product2(Name = 'Test Product', IsActive = true);
    ApexPages.StandardController sc = new ApexPages.StandardController(
      testProduct
    );

    Test.startTest();
    Product2Extension ext = new Product2Extension(sc);
    System.assertEquals(Constants.DEFAULT_ROWS, ext.productsToInsert.size());
    ext.addRows();
    System.assertEquals(
      Constants.DEFAULT_ROWS * 2,
      ext.productsToInsert.size()
    );

    for (Integer i = 0; i < Constants.DEFAULT_ROWS; i++) {
      Product2 newProduct = new Product2(
        IsActive = true,
        Initial_Inventory__c = 10,
        Family = Constants.PRODUCT_FAMILY[math.mod(i, 4)].getValue()
      );
      ext.productsToInsert[i].productRecord = newProduct;

      PricebookEntry newPricebookEntry = new PricebookEntry(UnitPrice = 5);
      ext.productsToInsert[i].pricebookEntryRecord = newPricebookEntry;
    }
    ext.save();
    ext.GetFamilyOptions();
    ext.GetInventory();
    List<Product2> testProducts = [SELECT Id FROM Product2];
    System.assertEquals(Constants.DEFAULT_ROWS, testProducts.size());

    Test.stopTest();
  }
}
