!function(t,e){"object"==typeof exports&&"undefined"!=typeof module?module.exports=e(require("@hotwired/stimulus"),require("lodash/debounce")):"function"==typeof define&&define.amd?define(["@hotwired/stimulus","lodash/debounce"],e):(t||self).smartListing=e(t.stimulus,t.debounce)}(this,function(t,e){function n(t){return t&&"object"==typeof t&&"default"in t?t:{default:t}}var r=n(e);function o(t,e){t.prototype=Object.create(e.prototype),t.prototype.constructor=t,i(t,e)}function i(t,e){return(i=Object.setPrototypeOf||function(t,e){return t.__proto__=e,t})(t,e)}var s=function(){function t(){}return t.register=function(t,e){this.registryList[t]=e},t.get=function(t){return this.registryList[t]},t}();s.registryList={};var a="beforesend",u="aftercomplete",c={reloadList:function(t,e){if(t&&e)return t.innerHTML=e.innerHTML;throw new Error("Target: "+t+", template: "+e)},remove:function(t){if(t)return t.remove();throw new Error("Target: "+t)}},l=function(t){function e(){return t.apply(this,arguments)||this}o(e,t);var n=e.prototype;return n.connect=function(){s.register(this.nameValue,this)},n.beforeSend=function(t){switch(console.log("before",t),t.type){case"ajax:beforeSend":t.detail[0].setRequestHeader("Accept","text/vnd.smart-listing-remote.html");break;case"turbo:before-fetch-request":Turbo.navigator.history.push(new URL(t.detail.url))}var e,n;return e=this.element,n=new Event(a),e.dispatchEvent(n),!0},n.performAction=function(t,e,n){switch(t){case"replace":return c.reloadList(e,n);case"remove":return c.remove(e);default:throw new Error("Unknown action: "+t)}},n.update=function(t){var e,n,r=this;if(console.log("update",t),"ajax:complete"==t.type){var o=t.detail,i=o[0];"OK"===o[1]?(new DOMParser).parseFromString(i.response,"text/html").querySelectorAll("smart-listing-action").forEach(function(t){var e=t.getAttribute("name"),n=t.getAttribute("target"),o=document.getElementById(""+n),i=t.querySelector("template");r.performAction(e,o,i)}):console.error("Status "+i.status)}e=this.element,n=new Event(u),e.dispatchEvent(n)},e}(t.Controller);l.values={name:String};var f=function(t){function e(){return t.apply(this,arguments)||this}return o(e,t),e.prototype.connect=function(){t.prototype.connect.call(this),console.log("hello from tailwind controller"),this.element.addEventListener(a,function(t){t.target.classList.add("opacity-25","pointer-events-none","transition-opacity")}),this.element.addEventListener(u,function(t){t.target.classList.remove("opacity-25","pointer-events-none")})},e}(l),p=function(t){function e(){return t.apply(this,arguments)||this}o(e,t);var n=e.prototype;return n.initialize=function(){this.refresh=r.default(this.refresh,500).bind(this)},n.connect=function(){},n.disconnect=function(){},n.refresh=function(t){console.log("refresh"),this.element.requestSubmit()},e}(t.Controller);p.targets=["observable"];var d={controllers:{main:{base:l,tailwind:f},controls:{base:p,tailwind:function(t){function e(){return t.apply(this,arguments)||this}return o(e,t),e}(p)}},registry:s,actions:c};return window.SmartListing=d,d});
//# sourceMappingURL=smart_listing.umd.js.map
