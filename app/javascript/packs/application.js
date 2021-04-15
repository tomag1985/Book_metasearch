// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)


// ----------------------------------------------------
// Note(lewagon): ABOVE IS RAILS DEFAULT CONFIGURATION
// WRITE YOUR OWN JS STARTING FROM HERE 👇
// ----------------------------------------------------

// External imports
import "bootstrap";

// Internal imports, e.g:
// import { initSelect2 } from '../components/init_select2';

document.addEventListener('turbolinks:load', () => {
  // Call your functions here, e.g:
  // initSelect2();
});


const ps = document.querySelectorAll('p');
const observer = new ResizeObserver(entries => {
  for (let entry of entries) {
    entry.target.classList[entry.target.scrollHeight > entry.contentRect.height ? 'add' : 'remove']('truncated');
  }
});

ps.forEach(p => {
  observer.observe(p);
});



var min = document.querySelector('.price-item');

const price = document.querySelectorAll('.price-item');

price.forEach((element => {
  if (parseInt(element.innerText.substring(1)) < parseInt(min.innerText.substring(1))) {
    min = element;
  }
}));

min = min.innerText;

for (const a of document.querySelectorAll(".price-item")) {
  if (a.textContent.includes(min)) {
    min = a.closest("#badge");
  }
}

const el = min.firstChild;

const sec = el.nextSibling;

const third = sec.firstChild;

const fourth = third.nextSibling;

const fifth = fourth.nextSibling;

const sixth = fifth.nextSibling;

sixth.style.display = "block";