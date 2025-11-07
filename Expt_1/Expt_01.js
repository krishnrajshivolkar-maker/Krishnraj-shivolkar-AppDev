// CRUD operations on an array

//Initial array
let fruits = ["Apple", "Banana", "Mango"];

console.log("Initial Array:", fruits);

//create
function createItem(item) {
  fruits.push(item);
  console.log(`Added "${item}" →`, fruits);
}

//read
function readItems() {
  console.log("Current items:", fruits);
}

//update
function updateItem(index, newItem) {
  if (index >= 0 && index < fruits.length) {
    console.log(`Updated "${fruits[index]}" to "${newItem}"`);
    fruits[index] = newItem;
  } else {
    console.log("Invalid index!");
  }
  console.log("Updated Array:", fruits);
}

//delete 
function deleteItem(index) {
  if (index >= 0 && index < fruits.length) {
    console.log(`Deleted "${fruits[index]}"`);
    fruits.splice(index, 1);
  } else {
    console.log("Invalid index!");
  }
  console.log("Array after deletion:", fruits);
}

//Example
createItem("Orange");   // add new fruit
readItems();            // display all fruits
updateItem(1, "Kiwi");  // change banana to Kiwi
deleteItem(0);          // remove first fruit 
readItems();            // display final array
