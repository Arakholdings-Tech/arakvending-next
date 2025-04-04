import { Controller } from "@hotwired/stimulus";
import { post } from "@rails/request.js";

export default class extends Controller {
  static values = { url: String };

  hasPosted = false;

  connect() {
    //post(this.urlValue);
    // Only make the POST request if we haven't already
    if (!this.hasPosted) {
      post(this.urlValue);
      this.hasPosted = true;

      console.log("Controller connected", this.element);
    }
  }
}
