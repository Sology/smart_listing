import BaseController from './controllers/base';
import TailwindController from './controllers/tailwind';
import Registry from './registry';

const SmartListing = {
  controllers: {
    base: BaseController,
    tailwind: TailwindController
  },
  registry: Registry,
};

window.SmartListing = SmartListing;

export default SmartListing;
