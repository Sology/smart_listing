import BaseController from './controllers/base';
import TailwindController from './controllers/tailwind';
import Registry from './registry';
import { actionsList } from './actions';

const SmartListing = {
  controllers: {
    base: BaseController,
    tailwind: TailwindController,
  },
  registry: Registry,
  actions: actionsList,
};

window.SmartListing = SmartListing;

export default SmartListing;
