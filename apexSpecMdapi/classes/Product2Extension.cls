public class Product2Extension {
  public List<ProductWrapper> productsToInsert { get; set; }

  public Product2Extension(ApexPages.StandardController controller) {
    productsToInsert = new List<ProductWrapper>();
    addRows();
  }

  public void AddRows() {
    for (Integer i = 0; i < Constants.DEFAULT_ROWS; i++) {
      productsToInsert.add(new ProductWrapper());
    }
  }

  public List<ChartHelper.ChartData> GetInventory() {
    return ChartHelper.GetInventory();
  }

  public PageReference Save() {
    Savepoint sp = Database.setSavepoint();
    try {
      List<Product2> products = new List<Product2>();
      List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
      for (ProductWrapper pw : productsToInsert) {
        if (
          pw.pricebookEntryRecord.UnitPrice != 0 &&
          pw.pricebookEntryRecord.UnitPrice != null &&
          !String.isBlank(pw.productRecord.Name) &&
          pw.productRecord.IsActive &&
          pw.productRecord.Initial_Inventory__c != 0 &&
          pw.productRecord.Initial_Inventory__c != null &&
          pw.productRecord.Family != Constants.SELECT_ONE
        ) {
          products.add(pw.productRecord);
          pricebookEntries.add(pw.pricebookEntryRecord);
        }
      }

      insert products;

      for (Integer i = 0; i < pricebookEntries.size(); i++) {
        pricebookEntries[i].Product2Id = products[i].Id;
        pricebookEntries[i].Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
        pricebookEntries[i].IsActive = true;
      }

      insert pricebookEntries;

      //If successful clear the list and display an informational message
      apexPages.addMessage(
        new ApexPages.message(
          ApexPages.Severity.INFO,
          productsToInsert.size() + ' Inserted'
        )
      );
      productsToInsert.clear(); //Do not remove
      addRows(); //Do not remove
    } catch (Exception e) {
      apexPages.addMessage(
        new ApexPages.message(ApexPages.Severity.ERROR, Constants.ERROR_MESSAGE)
      );
      Database.rollback(sp);
    }
    return null;
  }

  public List<SelectOption> GetFamilyOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
    for (Schema.PicklistEntry pe : Constants.PRODUCT_FAMILY) {
      options.add(new SelectOption(pe.getValue(), pe.getLabel()));
    }
    return options;
  }

  public class ProductWrapper {
    public Product2 productRecord { get; set; }
    public PriceBookEntry pricebookEntryRecord { get; set; }

    public ProductWrapper() {
      productRecord = new Product2(Initial_Inventory__c = 0);
      pricebookEntryRecord = new PricebookEntry(UnitPrice = 0.0);
    }
  }
}
