const sayings = [
  "Bless the Maker and His water. Bless the coming and going of Him.",
  "A beginning is the time for taking the most delicate care that the balances are correct.",
  "He who can destroy a thing has the real control of it.",
  "Seek freedom and become captive of your desires. Seek discipline and find your liberty.",
  "The mystery of life isn't a problem to solve, but a reality to experience.",
  "When religion and politics travel in the same cart, the riders believe nothing can stand in their way.",
];

const today = new Date();
const daySeed =
  today.getUTCFullYear() * 1000 +
  Math.floor((today - new Date(Date.UTC(today.getUTCFullYear(), 0, 0))) / 86400000);

const quote = sayings[daySeed % sayings.length];
const quoteNode = document.getElementById("daily-quote");

if (quoteNode) {
  quoteNode.textContent = `“${quote}”`;
}
