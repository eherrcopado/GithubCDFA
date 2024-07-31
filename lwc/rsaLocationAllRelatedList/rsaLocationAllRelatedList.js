import { api, LightningElement, wire } from 'lwc';
import { getRelatedListRecords } from 'lightning/uiRelatedListApi';

export default class RsaLocationAllRelatedList extends LightningElement {
    error;
    @api recordId;
    records;
    @wire(getRelatedListRecords, {
        parentRecordId: '001BZ000007KpRpYAK',
        relatedListId: 'AssociatedLocations'
    })listInfo({ error, data }) {
        if (data) {
            this.records = data.records;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.records = undefined;
        }
    }
}