import { Query } from "@/types/Query";

export const emptyQueryStringsToNull = (data: Query) => {
  Object.keys(data).forEach((key) => {
    if (data[key as keyof Query] === "") {
      data[key as keyof Query] = null;
    }
  });
};

export const generateLetter = () => {
  let currentLetter = "X";
  let usedLetters = new Set();
  let cycleCount = -1;

  return () => {
    if (currentLetter === "X") {
      cycleCount++;
    }
    if (currentLetter === "[") {
      currentLetter = "A";
    }

    let letterToReturn = currentLetter;

    if (usedLetters.has(letterToReturn)) {
      letterToReturn += cycleCount.toString();
      usedLetters.add(letterToReturn);
    } else {
      usedLetters.add(letterToReturn);
    }

    currentLetter = String.fromCharCode(currentLetter.charCodeAt(0) + 1);
    return letterToReturn;
  };
};
