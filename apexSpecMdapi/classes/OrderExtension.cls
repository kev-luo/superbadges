/**
 * @name OrderExtension
 * @description This class is provided for you to facilitate the Super Badge
 **/
public class OrderExtension {
  public Order orderRecord { get; set; }
  public List<OrderItem> orderItemList { get; set; }
  public String selectedFamily { get; set; }
  public List<chartHelper.chartData> pieData { get; set; }
  public Decimal total { get; set; }

  public Map<Id, OrderItem> orderItemMap;
  ApexPages.StandardSetController standardSetController;

  public OrderExtension(ApexPages.StandardController standardController) {
    orderRecord = (Order) standardController.getRecord();
    orderItemMap = new Map<id, OrderItem>();
    if (orderRecord.Id != null) {
      orderRecord = queryOrderRecord(orderRecord.Id);
    }
    loadInitOrderItemData();
    loadChartData();
    loadPriceBookEntries();
    loadOrderItems();
  }

  //ToDo: Implement your own method to populate orderItemList
  //  that you will call after pagination and/or family selection
  public void loadPriceBookEntries() {
    String query = 'SELECT Id, UnitPrice, Product2Id, Pricebook2Id, Name, Product2.Name, Product2.Quantity_Remaining__c, Product2.Family, IsActive FROM PricebookEntry WHERE IsActive = true';
    if (selectedFamily != Constants.SELECT_ONE && selectedFamily != null) {
      query += ' AND Product2.Family = \'' + selectedFamily + '\'';
    }
    System.debug('query: ====> ' + query);
    standardSetController = new ApexPages.StandardSetController(
      Database.getQueryLocator(query)
    );
    standardSetController.setPageSize(Constants.DEFAULT_ROWS);
  }

  public void loadOrderItems() {
    orderItemList = new List<OrderItem>();
    if (
      standardSetController.getRecords() != null &&
      standardSetController.getRecords().size() > 0
    ) {
      for (SObject obj : standardSetController.getRecords()) {
        PricebookEntry pbe = (PricebookEntry) obj;

        if (orderItemMap.containsKey(pbe.Product2Id)) {
          orderItemList.add(orderItemMap.get(pbe.Product2Id));
        } else {
          OrderItem oi = new OrderItem(
            Quantity = 0,
            PricebookEntryId = pbe.Id,
            Product2Id = pbe.Product2Id,
            UnitPrice = pbe.UnitPrice,
            Product2 = pbe.Product2
          );
          orderItemList.add(oi);
          orderItemMap.put(pbe.Product2Id, oi);
        }
      }
    }
  }

  public void loadInitOrderItemData() {
    for (OrderItem oi : orderRecord.OrderItems) {
      orderItemMap.put(oi.Product2Id, oi);
    }
  }

  public void loadChartData() {
    this.total = 0;
    pieData = new List<ChartHelper.ChartData>();
    for (OrderItem oi : orderItemMap.values()) {
      pieData.add(
        new ChartHelper.ChartData(
          oi.Product2.Name,
          (oi.UnitPrice * oi.Quantity)
        )
      );
      total += oi.UnitPrice * oi.Quantity;
    }
  }
  /**
   * @name OnFieldChange
   * @description
   **/
  public void OnFieldChange() {
    //ToDo: Implement logic to store the values changed on the page
    //      and populate pieData
    //      and populate total
    for (OrderItem oi : orderItemList) {
      orderItemMap.put(oi.Product2Id, oi);
    }

    loadChartData();
  }

  /**
   * @name SelectFamily
   * @description
   **/
  public void SelectFamily() {
    //ToDo: Implement logic to filter based on the selected product family
    loadPriceBookEntries();
    loadOrderItems();
  }

  /**
   * @name Save
   * @description
   **/
  public void Save() {
    //ToDo: Implement logic to save the Order and populated OrderItems
    System.Savepoint sp = Database.setSavepoint();
    try {
      if (orderRecord.Pricebook2Id == null) {
        orderRecord.Pricebook2Id = Constants.STANDARD_PRICEBOOK_ID;
      }
      upsert orderRecord;

      OrderItem[] upsertOrderItems = new List<OrderItem>();
      OrderItem[] deleteOrderItems = new List<OrderItem>();

      for (OrderItem oi : orderItemMap.values()) {
        if (oi.Quantity > 0) {
          if (oi.OrderId == null) {
            oi.OrderId = orderRecord.Id;
          }
          upsertOrderItems.add(oi);
        } else if (oi.Id != null) {
          deleteOrderItems.add(oi);
        }
      }

      upsert upsertOrderItems;
      delete deleteOrderItems;
    } catch (Exception e) {
      Database.rollback(sp);
      ApexPages.addMessage(
        new ApexPages.Message(ApexPages.Severity.INFO, Constants.ERROR_MESSAGE)
      );
    }
  }

  /**
   * @name First
   * @description
   **/
  public void First() {
    standardSetController.first();
    loadOrderItems();
  }

  /**
   * @name Next
   * @description
   **/
  public void Next() {
    standardSetController.next();
    loadOrderItems();
  }

  /**
   * @name Previous
   * @description
   **/
  public void Previous() {
    standardSetController.previous();
    loadOrderItems();
  }

  /**
   * @name Last
   * @description
   **/
  public void Last() {
    standardSetController.last();
    loadOrderItems();
  }

  /**
   * @name GetHasPrevious
   * @description
   **/
  public Boolean GetHasPrevious() {
    return standardSetController.getHasPrevious();
  }

  /**
   * @name GetHasNext
   * @description
   **/
  public Boolean GetHasNext() {
    return standardSetController.getHasNext();
  }

  /**
   * @name GetTotalPages
   * @description
   **/
  public Integer GetTotalPages() {
    Integer pages = (Integer) math.ceil(
      standardSetController.getResultSize() / (Decimal) Constants.DEFAULT_ROWS
    );
    return pages;
  }

  /**
   * @name GetPageNumber
   * @description
   **/
  public Integer GetPageNumber() {
    return standardSetController.getPageNumber();
  }

  /**
   * @name GetFamilyOptions
   * @description
   **/
  public List<SelectOption> GetFamilyOptions() {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption(Constants.SELECT_ONE, Constants.SELECT_ONE));
    for (Schema.PicklistEntry pe : Constants.PRODUCT_FAMILY) {
      options.add(new SelectOption(pe.getValue(), pe.getLabel()));
    }
    return options;
  }

  /**
   * @name QueryOrderRecord
   * @description
   **/
  public static Order QueryOrderRecord(Id orderId) {
    return [
      SELECT
        Id,
        AccountId,
        EffectiveDate,
        Name,
        Status,
        Pricebook2Id,
        (
          SELECT
            Id,
            OrderId,
            Quantity,
            UnitPrice,
            PricebookEntryId,
            Product2Id,
            Product2.Name,
            Product2.Family,
            Product2.Quantity_Remaining__c
          FROM OrderItems
        )
      FROM Order
      WHERE Id = :orderId
    ];
  }
}
