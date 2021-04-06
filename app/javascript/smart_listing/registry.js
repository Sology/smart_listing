class SmartListingRegistry {
  static registryList = {};

  static register(name, stimulusController) {
    this.registryList[name] = stimulusController;
  }

  static get(name) {
    return this.registryList[name];
  }
}

export default SmartListingRegistry;
