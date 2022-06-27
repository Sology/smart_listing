import MainBaseController from './controllers/main/base';
import MainTailwindController from './controllers/main/tailwind';
import ControlsBaseController from './controllers/controls/base';
import ControlsTailwindController from './controllers/controls/tailwind';
import Registry from './registry';
import { actionsList } from './actions';

const SmartListing = {
  controllers: {
    main: {
      base: MainBaseController,
      tailwind: MainTailwindController
    },
    controls: {
      base: ControlsBaseController,
      tailwind: ControlsTailwindController
    }
  },
  registry: Registry,
  actions: actionsList,
};

window.SmartListing = SmartListing;

export default SmartListing;
