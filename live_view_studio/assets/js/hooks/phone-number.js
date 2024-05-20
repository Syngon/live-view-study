import { AsYouType } from "../../vendor/libphonenumber-js/build/libphonenumber-js.min.js";

let PhoneNumber = {
  mounted() {
    this.el.addEventListener("input", (e) => {
      this.el.value = new AsYouType("US").input(this.el.value);
    });
  },
};

export default PhoneNumber;
