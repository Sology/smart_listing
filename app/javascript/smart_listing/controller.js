import { Controller } from 'stimulus';
import Registry from './registry';

const STATUS_OK = 'OK';

export default class extends Controller {
  static values = { name: String };

  connect() {
    Registry.register(this.nameValue, this);
  }

  update(e) {
    const [xhr, status] = e.detail;
    const tableBody = this.element.querySelector('tbody');

    if (status === STATUS_OK) {
      this.element.outerHTML = xhr.response;
    } else {
      tableBody.textContent = 'Failed to load data!';
    }
  }
}
