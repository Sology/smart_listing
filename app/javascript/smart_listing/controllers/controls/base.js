import { Controller } from '@hotwired/stimulus';
import debounce from 'lodash/debounce';

export default class extends Controller {
  static targets = ['observable'];

  initialize() {
    this.refresh = debounce(this.refresh, 500).bind(this)
  }

  connect() {
    //document.addEventListener('turbo:submit-start', this.appendTurboToHeaders);
  }

  disconnect() {
    //window.removeEventListener('turbo:submit-start', this.appendTurboToHeaders);
  }

  //beforeSend(e) {
    //console.log('beforeSend');
    //console.log(e.detail);
    //debugger;
    //headers["Accept"] = [ StreamMessage.contentType, headers["Accept"] ].join(", ")
  //}

  refresh(e) {
    console.log('smart listing controls: refresh', e);
    this.element.requestSubmit();
  }

  //appendTurboToHeaders(e) {
    //console.log('append');
    //console.log(e);
  //}
}
