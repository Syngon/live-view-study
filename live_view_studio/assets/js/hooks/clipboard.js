let Clipboard = {
  mounted() {
    const initialInnerHTML = this.el.innerHTML;
    const { content } = this.el.dataset;

    this.el.addEventListener("click", () => {
      navigator.clipboard.writeText(content);

      this.el.innerHTML = "Copied!";
      console.log("Copied!");

      setTimeout(() => {
        this.el.innerHTML = initialInnerHTML;
      }, 2000);
    });
  },
};

export default Clipboard;
