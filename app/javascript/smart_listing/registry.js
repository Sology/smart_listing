class SmartListingRegistry {
  static registryList = {};

  static register(name, controllerInstance) {
    this.registryList[name] = controllerInstance;
  }

  static get(name) {
    return this.registryList[name];
  }
}

export default SmartListingRegistry;
