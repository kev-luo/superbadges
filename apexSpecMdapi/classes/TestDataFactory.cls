/**
 * @name TestDataFactory
 * @description Contains methods to construct and/or validate commonly used records
 **/
public with sharing class TestDataFactory {
  /**
   * @name ConstructCollaborationGroup
   * @description
   **/
  public static CollaborationGroup ConstructCollaborationGroup() {
    return new CollaborationGroup(
      Name = 'TEST' + Constants.INVENTORY_ANNOUNCEMENTS,
      CollaborationType = 'Public'
    );
    // Ensure this method returns a single Chatter CollaborationGroup
    //    whose Name starts with 'TEST' followed by the INVENTORY_ANNOUNCEMENTS constant
    //    and configured so anyone can join, see and post updates.
  }

  /**
   * @name CreateProducts
   * @description Constructs a list of Product2 records for unit tests
   **/
  public static List<Product2> ConstructProducts(Integer cnt) {
    List<Product2> testProducts = new List<Product2>();
    for (Integer i = 0; i < cnt; i++) {
      testProducts.add(
        new Product2(
          Name = 'Test Product ' + cnt,
          Family = Constants.PRODUCT_FAMILY[math.mod(i, 4)].getValue(),
          IsActive = true,
          Initial_Inventory__c = 10
        )
      );
    }
    return testProducts;
    // Ensure this method returns a list, of size cnt, of uniquely named Product2 records
    //  with all the required fields populated
    //  and IsActive = true
    //  an Initial Inventory set to 10
    //  and iterating through the product family picklist values throughout the list.
  }

  /**
   * @name CreatePricebookEntries
   * @description Constructs a list of PricebookEntry records for unit tests
   **/
  public static List<PricebookEntry> ConstructPricebookEntries(
    List<Product2> prods
  ) {
    List<PricebookEntry> testPricebookEntries = new List<PricebookEntry>();
    for (Product2 prod : prods) {
      testPricebookEntries.add(
        new PricebookEntry(
          Product2Id = prod.Id,
          Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID,
          UnitPrice = 10,
          IsActive = true
        )
      );
    }
    return testPricebookEntries;
    // Ensure this method returns a corresponding list of PricebookEntries records
    //  related to the provided Products
    //  with all the required fields populated
    //  and IsActive = true
    //  and belonging to the standard Pricebook
  }

  /**
   * @name CreateAccounts
   * @description Constructs a list of Account records for unit tests
   **/
  public static List<Account> ConstructAccounts(Integer cnt) {
    List<Account> testAccounts = new List<Account>();
    for (Integer i = 0; i < cnt; i++) {
      testAccounts.add(new Account(Name = 'Test Account ' + i));
    }
    return testAccounts;
    // Ensure this method returns a list of size cnt of uniquely named Account records
    //  with all of the required fields populated.
  }

  /**
   * @name CreateContacts
   * @description Constructs a list of Contacxt records for unit tests
   **/
  public static List<Contact> ConstructContacts(
    Integer cnt,
    List<Account> accts
  ) {
    List<Contact> testContacts = new List<Contact>();
    for (Integer i = 0; i < cnt; i++) {
      testContacts.add(
        new Contact(LastName = 'Test Contact ' + i, AccountId = accts[i].Id)
      );
    }
    return testContacts;
    // Ensure this method returns a list, of size cnt, of uniquely named Contact records
    //  related to the provided Accounts
    //  with all of the required fields populated.
  }

  /**
   * @name CreateOrders
   * @description Constructs a list of Order records for unit tests
   **/
  public static List<Order> ConstructOrders(Integer cnt, List<Account> accts) {
    List<Order> testOrders = new List<Order>();
    for (Integer i = 0; i < cnt; i++) {
      testOrders.add(
        new Order(
          AccountId = accts[i].Id,
          Status = Constants.DRAFT_ORDER_STATUS,
          Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID,
          EffectiveDate = System.today()
        )
      );
    }
    return testOrders;
    // Ensure this method returns a list of size cnt of uniquely named Order records
    //  related to the provided Accounts
    //  with all of the required fields populated.
  }

  /**
   * @name CreateOrderItems
   * @description Constructs a list of OrderItem records for unit tests
   **/
  public static List<OrderItem> ConstructOrderItems(
    integer cnt,
    list<pricebookentry> pbes,
    list<order> ords
  ) {
    List<OrderItem> testOrderItems = new List<OrderItem>();
    for (Integer i = 0; i < cnt; i++) {
      testOrderItems.add(
        new OrderItem(
          OrderId = ords[i].Id,
          PricebookEntryId = pbes[i].Id,
          Quantity = Constants.DEFAULT_ROWS,
          UnitPrice = 10
        )
      );
    }
    return testOrderItems;
    // Ensure this method returns a list of size cnt of OrderItem records
    //  related to the provided Pricebook Entries
    //  and related to the provided Orders
    //  with all of the required fields populated.
    //  Hint: Use the DEFAULT_ROWS constant for Quantity as it will be used in the next challenge
  }

  /**
   * @name SetupTestData
   * @description Inserts accounts, contacts, Products, PricebookEntries, Orders, and OrderItems.
   **/
  public static void InsertTestData(Integer cnt) {
    insert TestDataFactory.ConstructCollaborationGroup();

    List<Product2> testProducts = TestDataFactory.ConstructProducts(cnt);
    insert testProducts;

    List<PricebookEntry> testPricebookEntries = TestDataFactory.ConstructPricebookEntries(
      testProducts
    );
    insert testPricebookEntries;

    List<Account> testAccounts = TestDataFactory.ConstructAccounts(cnt);
    insert testAccounts;

    List<Contact> testContacts = TestDataFactory.ConstructContacts(
      cnt,
      testAccounts
    );
    insert testContacts;

    List<Order> testOrders = TestDataFactory.ConstructOrders(cnt, testAccounts);
    insert testOrders;

    List<OrderItem> testOrderItems = TestDataFactory.ConstructOrderItems(
      cnt,
      testPricebookEntries,
      testOrders
    );
    insert testOrderItems;
    //TODO: Ensure this method calls each of the construct methods
    //  and inserts the results for use as test data.
  }

  public static void VerifyQuantityOrdered(
    Product2 originalProduct,
    Product2 updatedProduct,
    Integer qtyOrdered
  ) {
    System.assertEquals(
      updatedProduct.Quantity_Ordered__c - originalProduct.Quantity_Ordered__c,
      qtyOrdered
    );
  }
}
