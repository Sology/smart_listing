import SmartListing from './index';

class SmartListingRegistry {
  static register(element) {
    SmartListing.registry[`${element.id}`] = element;
  }

  static get(elementId) {
    return SmartListing.registry[`${elementId}`];
  }
}

export default SmartListingRegistry;
