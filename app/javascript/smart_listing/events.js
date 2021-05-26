export const eventsName = {
  BEFORE_SEND: 'beforesend',
  AFTER_COMPLETE: 'aftercomplete',
};

export const dispatchBeforeSendEvent = (htmlElement, data) => {
  const beforeSendEvent = new CustomEvent(eventsName.BEFORE_SEND, {
    detail: data,
  });
  htmlElement.dispatchEvent(beforeSendEvent);
};

export const dispatchAfterCompleteEvent = (htmlElement, data) => {
  const afterCompleteEvent = new CustomEvent(eventsName.AFTER_COMPLETE, {
    detail: data,
  });
  htmlElement.dispatchEvent(afterCompleteEvent);
};
