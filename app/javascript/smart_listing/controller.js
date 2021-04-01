import { Controller } from 'stimulus';
import SmartListingRegistry from './register';

export default class extends Controller {
  static targets = [ "name", "output", "boobzz" ]

  connect() {
    console.log(this);
    SmartListingRegistry.register(this.element);
  }
}
