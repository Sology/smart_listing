import { Controller } from '@hotwired/stimulus';
import Registry from '../../registry';
import { dispatchBeforeSendEvent, dispatchAfterCompleteEvent } from '../../events';
import { actionNames, actionsList } from '../../actions';

const STATUS_OK = 'OK';

export default class extends Controller {
  static values = { name: String };

  connect() {
    Registry.register(this.nameValue, this);
  }

  beforeSend(e) {
    console.log('before', e);

    switch(e.type) {
      case 'ajax:beforeSend':
        e.detail[0].setRequestHeader('Accept', 'text/vnd.smart-listing-remote.html');
        break;
      case 'turbo:before-fetch-request':
        Turbo.navigator.history.push(new URL(e.detail.url))
        break;
    }

    dispatchBeforeSendEvent(this.element);

    return true;
  }

  performAction(action, target, template) {
    switch (action) {
      case actionNames.REPLACE:
        return actionsList.reloadList(target, template);
      case actionNames.REMOVE:
        return actionsList.remove(target);
      default:
        throw new Error(`Unknown action: ${action}`);
    }
  }

  update(e) {
    console.log('update', e);
    if(e.type == 'ajax:complete') {
      // UJS mode
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

          this.performAction(actionName, target, template);
        });
      } else {
        console.error(`Status ${xhr.status}`);
      }
    }

    dispatchAfterCompleteEvent(this.element);
  }
}
