document.addEventListener("DOMContentLoaded", () => {
  const search = document.getElementById("search");
  const treeItems = document.querySelectorAll("#source-tree .tree-item");
  const rows = document.querySelectorAll("[data-text]");

  // Non-index pages (e.g. skill detail) load this script too but have no filter UI.
  if (!search) return;

  let activeSource = "";

  const apply = () => {
    const query = search.value.trim().toLowerCase();
    rows.forEach((row) => {
      const matchesSource = !activeSource || row.dataset.source === activeSource;
      const matchesQuery = !query || row.dataset.text.includes(query);
      row.classList.toggle("hidden", !(matchesSource && matchesQuery));
    });
  };

  search.addEventListener("input", apply);

  treeItems.forEach((item) => {
    item.addEventListener("click", () => {
      treeItems.forEach((i) => i.classList.remove("on"));
      item.classList.add("on");
      activeSource = item.dataset.source;
      apply();
    });
  });

  const modal = document.getElementById("skill-modal");
  const modalBody = document.getElementById("modal-body");

  rows.forEach((row) => {
    row.addEventListener("click", async () => {
      const { source, name } = row.dataset;
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
