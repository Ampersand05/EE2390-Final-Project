Rough outline on possible implementation for the Lap Function

  - Add a variable lap and lapping
  - Add E F G H inputs for hex values

  - when lapping is false, the stopwatch functions normally
  - when on the rising edge of lap, set lapping to true, and four values E F G H are assigned the current A B C D values
  - the mux chooses from E F G H to display while lapping is true
  - on rising edge of start, lapping is set to false
