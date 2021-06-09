import{Controller as t}from"stimulus";function e(t,e){t.prototype=Object.create(e.prototype),t.prototype.constructor=t,r(t,e)}function r(t,e){return(r=Object.setPrototypeOf||function(t,e){return t.__proto__=e,t})(t,e)}var n=function(){function t(){}return t.register=function(t,e){this.registryList[t]=e},t.get=function(t){return this.registryList[t]},t}();n.registryList={};var o={reloadList:function(t,e){if(t&&e)return t.innerHTML=e.innerHTML;throw new Error("Target: "+t+", template: "+e)},remove:function(t){if(t)return t.remove();throw new Error("Target: "+t)}},i=function(t){function r(){return t.apply(this,arguments)||this}e(r,t);var i=r.prototype;return i.connect=function(){n.register(this.nameValue,this)},i.beforeSend=function(t){var e,r;return console.log("before"),t.detail[0].setRequestHeader("Accept","text/vnd.smart-listing-remote.html"),e=this.element,r=new Event("beforesend"),e.dispatchEvent(r),!0},i.performAction=function(t,e,r){switch(t){case"replace":return o.reloadList(e,r);case"remove":return o.remove(e);default:throw new Error("Unknown action: "+t)}},i.update=function(t){var e=this;console.log("update");var r,n,o=t.detail,i=o[0];"OK"===o[1]?(new DOMParser).parseFromString(i.response,"text/html").querySelectorAll("smart-listing-action").forEach(function(t){var r=t.getAttribute("name"),n=t.getAttribute("target"),o=document.getElementById(""+n),i=t.querySelector("template");e.performAction(r,o,i)}):console.error("Status "+i.status),r=this.element,n=new Event("aftercomplete"),r.dispatchEvent(n)},r}(t);i.values={name:String};var s={controllers:{base:i,tailwind:function(t){function r(){return t.apply(this,arguments)||this}return e(r,t),r.prototype.connect=function(){t.prototype.connect.call(this),console.log("hello from tailwind controller"),this.element.addEventListener("beforesend",function(t){t.target.classList.add("opacity-20","pointer-events-none","transition-opacity")}),this.element.addEventListener("aftercomplete",function(t){t.target.classList.remove("opacity-20","pointer-events-none")})},r}(i)},registry:n,actions:o};window.SmartListing=s;export default s;
//# sourceMappingURL=smart_listing.module.js.map
