import { Controller } from 'stimulus';
import Registry from './registry';
import { dispatchBeforeSendEvent, dispatchAfterCompleteEvent } from './events';

const STATUS_OK = 'OK';

export default class extends Controller {
  static values = { name: String };

  connect() {
    Registry.register(this.nameValue, this);
  }

  beforeSend(e) {
    console.log('before');
    e.detail[0].setRequestHeader('Accept', 'text/vnd.smart-listing.html');

    dispatchBeforeSendEvent(this.element);

    return true;
  }

  makeAction(action, target, template) {
    switch (action) {
      case 'index':
        if (target && template) {
          return (target.innerHTML = template.innerHTML);
        }
        throw new Error(`Target: ${target}, template: ${template}`);
      default:
        throw new Error(`Unknown action: ${action}`);
    }
  }

  update(e) {
    console.log('update');
    const [xhr, status] = e.detail;

    if (status === STATUS_OK) {
      const parser = new DOMParser();
      const tempDoc = parser.parseFromString(xhr.response, 'text/html');

      const smartListingActionNodes = tempDoc.querySelectorAll('smart-listing-action');

      smartListingActionNodes.forEach((element) => {
        const actionName = element.getAttribute('name');
        const targetId = element.getAttribute('target');
        const target = document.getElementById(`${targetId}`);
        const template = element.querySelector('template');

        this.makeAction(actionName, target, template);
      });
    } else {
      console.error(`Status ${xhr.status}`);
    }

    dispatchAfterCompleteEvent(this.element);
  }
}
