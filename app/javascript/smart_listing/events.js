export const eventsName = {
  BEFORE_SEND: 'beforesend',
  AFTER_COMPLETE: 'aftercomplete',
};

export const dispatchBeforeSendEvent = (htmlElement) => {
  const beforeSendEvent = new Event(eventsName.BEFORE_SEND);
  htmlElement.dispatchEvent(beforeSendEvent);
};

export const dispatchAfterCompleteEvent = (htmlElement) => {
  const afterCompleteEvent = new Event(eventsName.AFTER_COMPLETE);
  htmlElement.dispatchEvent(afterCompleteEvent);
};
