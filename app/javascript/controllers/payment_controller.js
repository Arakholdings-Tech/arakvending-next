import { Controller } from "@hotwired/stimulus";
import { post } from "@rails/request.js";

export default class extends Controller {
  static values = { url: String };

  hasPosted = false;

  connect() {
    if (!this.hasPosted) {
      post(this.urlValue);
      this.hasPosted = true;

      console.log("Controller connected", this.element);
    }
  }
}
