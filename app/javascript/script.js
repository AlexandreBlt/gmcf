document.addEventListener("DOMContentLoaded", () => {
  const modal = document.getElementById("myModal");
  const openBtn = document.getElementById("openModal");
  const closeBtn = document.querySelector(".close");

  openBtn.addEventListener("click", () => {
    modal.style.display = "flex";
  });

  closeBtn.addEventListener("click", () => {
    modal.style.display = "none";
  });

  window.addEventListener("click", (e) => {
    if (e.target === modal) {
      modal.style.display = "none";
    }
  });
});
