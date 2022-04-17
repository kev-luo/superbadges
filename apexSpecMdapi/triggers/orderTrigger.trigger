/**
 * @name orderTrigger
 * @description
 **/
trigger orderTrigger on Order(after update) {
  try {
    if (Trigger.New != null) {
      OrderHelper.AfterUpdate(Trigger.new, Trigger.old);
    }
  } catch (Exception e) {
  }
}
