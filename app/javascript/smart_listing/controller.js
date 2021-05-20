import { Controller } from 'stimulus';
import Registry from './registry';

const STATUS_OK = 'OK';

export default class extends Controller {
  static values = { name: String };

  connect() {
    Registry.register(this.nameValue, this);
  }

  beforeSend(e) {
    console.log('before');
    e.detail[0].setRequestHeader('Accept', 'text/vnd.smart-listing.html');

    return true;
  }

  update(e) {
    console.log('update');
    const [xhr, status] = e.detail;
    const tableBody = this.element.querySelector('tbody');

    if (status === STATUS_OK) {
      this.element.outerHTML = xhr.response;
    } else {
      tableBody.textContent = 'Failed to load data!';
    }
  }
}
