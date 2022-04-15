import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import getAllReviews from '@salesforce/apex/BoatDataService.getAllReviews';

// imports
export default class BoatReviews extends NavigationMixin(LightningElement) {
    // Private
    @track
    boatId;
    @track
    error;
    @track
    boatReviews;
    @track
    isLoading;
    
    // Getter and Setter to allow for logic to run on recordId change
    @api
    get recordId() {
        return this.boatId;
     }
    set recordId(value) {
      //sets boatId attribute
      this.setAttribute('boat-id', value);
      //sets boatId assignment
      this.boatId = value;
      //get reviews associated with boatId
      this.getReviews();
    }
    
    // Getter to determine if there are reviews to display
    get reviewsToShow() {
        return this.boatReviews != null && this.boatReviews != undefined && this.boatReviews.length > 0;
     }
    
    // Public method to force a refresh of the reviews invoking getReviews
    @api
    refresh() {
        this.getReviews();
     }
    
    // Imperative Apex call to get reviews for given boat
    // returns immediately if boatId is empty or null
    // sets isLoading to true during the process and false when it’s completed
    // Gets all the boatReviews from the result, checking for errors.
    getReviews() {
        if(this.boatId == null || this.boatId == '') {
            return;
        }
        this.isLoading = true;
        this.error = undefined;
        getAllReviews({ boatId: this.boatId })
        .then(result => {
            this.boatReviews = result;
            })
        .catch(error => {
            this.boatReviews = undefined;
            this.error = error.body.message;
            })
        .finally(() => {
            this.isLoading = false;
        });

     }
    
    // Helper method to use NavigationMixin to navigate to a given record on click
    navigateToRecord(event) {
        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                // recordId: this.template.querySelector("a").dataset.recordId,
                recordId: event.target.dataset.recordId,
                objectApiName: 'User',
                actionName: 'view'
            }
        });
      }
}
  