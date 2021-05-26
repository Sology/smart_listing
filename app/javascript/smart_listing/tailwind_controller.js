import Controller from './controller';
import { eventsName } from './events';

export default class TailwindSmartListingController extends Controller {
  connect() {
    this.element.addEventListener(eventsName.BEFORE_SEND, (e) => {
      e.target.classList.add('opacity-20', 'pointer-events-none', 'transition-opacity');
    });
    this.element.addEventListener(eventsName.AFTER_COMPLETE, (e) => {
      e.target.classList.remove('opacity-20', 'pointer-events-none');
    });
  }
}
