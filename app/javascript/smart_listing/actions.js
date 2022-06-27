export const actionNames = {
  REPLACE: 'replace',
  REMOVE: 'remove',
};

export const actionsList = {
  reloadList: (target, template) => {
    if (target && template) {
      return (target.innerHTML = template.innerHTML);
    }
    throw new Error(`Target: ${target}, template: ${template}`);
  },
  remove: (target) => {
    if (target) {
      return target.remove();
    }
    throw new Error(`Target: ${target}`);
  },
};
