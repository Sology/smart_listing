import { Controller } from 'stimulus';
import SmartListingRegistry from './register';

export default class extends Controller {
  connect() {
    console.log(this);
    SmartListingRegistry.register(this.element);
  }
}
