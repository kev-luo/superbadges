public class Product2Helper {
  /**
   * @name COLLABORATION_GROUP
   * @description List of CollaborationGroup used in both business and test logic
   **/
  static List<CollaborationGroup> COLLABORATION_GROUP = [
    SELECT Id
    FROM CollaborationGroup
    WHERE
      Name = :Constants.INVENTORY_ANNOUNCEMENTS
      OR Name = :('TEST' + Constants.INVENTORY_ANNOUNCEMENTS)
    LIMIT 1
  ];

  /**
   * @name afterUpdate
   * @description called by product2 Trigger on After Update
   * @param List<Product2> newList
   * @param List<Product2> oldList
   **/
  public static void AfterUpdate(
    List<Product2> newList,
    List<Product2> oldList
  ) {
    //ToDo: Declare a List of Product2 records named needsAnnouncement
    List<Product2> needsAnnouncement = new List<Product2>();
    //ToDo: Declare a Map of Strings to Inventory_Setting__mdt records
    Map<String, Inventory_Setting__mdt> invLevelMap = new Map<String, Inventory_Setting__mdt>();
    //ToDo: Loop through a query of Inventory_Setting__mdt records and populate the Map with Name as the key
    for (Inventory_Setting__mdt invSetting : [
      SELECT Id, DeveloperName, Low_Quantity_Alert__c
      FROM Inventory_Setting__mdt
    ]) {
      invLevelMap.put(invSetting.DeveloperName, invSetting);
    }
    //ToDo: Loop through the Products in newList
    for (Product2 updatedProd : newList) {
      if (
        updatedProd.Quantity_Remaining__c <
        invLevelMap.get(updatedProd.Family).Low_Quantity_Alert__c
      ) {
        needsAnnouncement.add(updatedProd);
      }
    }
    // Use the corresponding Inventory Setting record to determine the correct Low Quantity Alert
    // If the Product's Quantity Remaining has been changed to less than the Low Quantity Alert
    //      add it to the needsAnnouncement list

    //ToDo: Pass records to the postAlerts method
    PostAlerts(needsAnnouncement);
  }

  /**
   * @name postAlerts
   * @description called by product2 Trigger on After Update
   * @param List<Product2> productList
   **/
  public static void PostAlerts(List<Product2> productList) {
    List<ConnectApi.AnnouncementInput> toPost = new List<ConnectApi.AnnouncementInput>();
    for (Product2 p : productList) {
      // ToDo: Construct a new AnnouncementInput for the Chatter Group so that it:
      // expires in a day
      // does not notify users via email.
      // and has a text body that includes the name of the product followed by the INVENTORY_LEVEL_LOW constant
      ConnectApi.AnnouncementInput a = new ConnectApi.AnnouncementInput();
      a.expirationDate = Date.today().addDays(1);
      a.sendEmails = false;
      a.parentId = COLLABORATION_GROUP[0].Id;

      ConnectApi.MessageBodyInput msgBody = new ConnectApi.MessageBodyInput();
      ConnectApi.TextSegmentInput textInput = new ConnectApi.TextSegmentInput();
      textInput.text = p.Name + ' ' + Constants.INVENTORY_LEVEL_LOW;
      msgBody.messageSegments = new List<ConnectApi.TextSegmentInput>();
      msgBody.messageSegments.add(textInput);
      a.body = msgBody;
      toPost.add(a);
    }
    // ToDo: Create and enqueue an instance of the announcementQueuable class with the list of Products
    AnnouncementQueueable q = new AnnouncementQueueable();
    q.toPost = toPost;
    System.enqueueJob(q);
  }
}
