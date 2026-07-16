document.addEventListener("DOMContentLoaded", () => {
  const search = document.getElementById("search");
  const chips = document.querySelectorAll("#chips .chip");
  const cards = document.querySelectorAll(".grid .card");

  // Non-index pages (e.g. skill detail) load this script too but have no filter UI.
  if (!search) return;

  let activeSource = "";

  const apply = () => {
    const query = search.value.trim().toLowerCase();
    cards.forEach((card) => {
      const matchesSource = !activeSource || card.dataset.source === activeSource;
      const matchesQuery = !query || card.dataset.text.includes(query);
      card.classList.toggle("hidden", !(matchesSource && matchesQuery));
    });
  };

  search.addEventListener("input", apply);

  chips.forEach((chip) => {
    chip.addEventListener("click", () => {
      chips.forEach((c) => c.classList.remove("active"));
      chip.classList.add("active");
      activeSource = chip.dataset.source;
      apply();
    });
  });

  const modal = document.getElementById("skill-modal");
  const modalBody = document.getElementById("modal-body");

  cards.forEach((card) => {
    card.addEventListener("click", async () => {
      const { source, name } = card.dataset;
      const url = `/skills/${encodeURIComponent(source)}/${encodeURIComponent(name)}`;
      const res = await fetch(`${url}?embed=1`);
      modalBody.innerHTML = await res.text();
      modalBody.insertAdjacentHTML(
        "afterbegin",
        `<p class="modal-link"><a href="${url}">開啟完整頁面 →</a></p>`
      );
      modal.showModal();
    });
  });

  modal.querySelector(".modal-close").addEventListener("click", () => modal.close());
  modal.addEventListener("click", (e) => {
    if (e.target === modal) modal.close();
  });
});
