import flatpickr from "../vendor/flatpickr";

let Calendar = {
  mounted() {
    this.pickr = flatpickr(this.el, {
      inline: true,
      mode: "range",
      showMonths: 2,
      onChange: (selectedDates) => {
        if (selectedDates.length != 2) return;
        this.pushEvent("dates-picked", selectedDates);
      },
    });

    this.handleEvent("add-unavailable-dates", (dates) => {
      this.pickr.set("disable", [dates, ...this.pickr.config.disable]);
    });

    this.pushEvent("unavailable-dates-request", {}, (reply, ref) => {
      this.pickr.set("disable", reply.dates);
    });
  },

  destroyed() {
    this.pickr.destroy();
  },
};

export default Calendar;
