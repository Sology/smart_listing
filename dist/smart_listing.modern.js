import{Controller as e}from"stimulus";class t{static register(e,t){this.registryList[e]=t}static get(e){return this.registryList[e]}}t.registryList={};const r={reloadList:(e,t)=>{if(e&&t)return e.innerHTML=t.innerHTML;throw new Error(`Target: ${e}, template: ${t}`)},remove:e=>{if(e)return e.remove();throw new Error(`Target: ${e}`)}};class n extends e{connect(){t.register(this.nameValue,this)}beforeSend(e){return console.log("before"),e.detail[0].setRequestHeader("Accept","text/vnd.smart-listing-remote.html"),(e=>{const t=new Event("beforesend");e.dispatchEvent(t)})(this.element),!0}performAction(e,t,n){switch(e){case"replace":return r.reloadList(t,n);case"remove":return r.remove(t);default:throw new Error(`Unknown action: ${e}`)}}update(e){console.log("update");const[t,r]=e.detail;"OK"===r?(new DOMParser).parseFromString(t.response,"text/html").querySelectorAll("smart-listing-action").forEach(e=>{const t=e.getAttribute("name"),r=e.getAttribute("target"),n=document.getElementById(`${r}`),s=e.querySelector("template");this.performAction(t,n,s)}):console.error(`Status ${t.status}`),(e=>{const t=new Event("aftercomplete");e.dispatchEvent(t)})(this.element)}}n.values={name:String};const s={controllers:{base:n,tailwind:class extends n{connect(){super.connect(),console.log("hello from tailwind controller"),this.element.addEventListener("beforesend",e=>{e.target.classList.add("opacity-25","pointer-events-none","transition-opacity")}),this.element.addEventListener("aftercomplete",e=>{e.target.classList.remove("opacity-25","pointer-events-none")})}}},registry:t,actions:r};window.SmartListing=s;export default s;
//# sourceMappingURL=smart_listing.modern.js.map
