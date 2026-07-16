document.addEventListener("DOMContentLoaded", () => {
  const search = document.getElementById("search");
  const chips = document.querySelectorAll("#chips .chip");
  const cards = document.querySelectorAll(".grid .card");

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
});
