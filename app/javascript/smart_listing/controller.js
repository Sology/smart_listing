import { Controller } from 'stimulus';
import Registry from './registry';

export default class extends Controller {
  static values = { name: String };

  connect() {
    Registry.register(this.nameValue, this);
  }
}
