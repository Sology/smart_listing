export const actionNames = {
  INDEX: 'index',
};

export const actionsList = {
  reloadList: (target, template) => {
    if (target && template) {
      return (target.innerHTML = template.innerHTML);
    }
    throw new Error(`Target: ${target}, template: ${template}`);
  },
};
