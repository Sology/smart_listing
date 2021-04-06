import { Controller } from 'stimulus';
import SmartListingRegistry from './registry';

export default class extends Controller {
  static values = { name: String };

  connect() {
    SmartListingRegistry.register(this.nameValue, this);
  }
}
