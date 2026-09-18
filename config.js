window.DEAL_BOARD_CONFIG = {
  SUPABASE_URL: "https://bisudvsrxmsuyuhgozcs.supabase.co",
  SUPABASE_ANON_KEY: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpc3VkdnNyeG1zdXl1aGdvemNzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgzNTYxMDcsImV4cCI6MjEwMzkzMjEwN30.gAOa3ncQ_ahV9NM5bNb96DvfzDydBhbkMl3N-8Wy-08",
};
// Broker link codes — keep the broker's name out of the visible URL.
//   byCode:  short code -> first name shown on the questionnaire.
//   byEmail: signed-in broker's email -> the code the board stamps into a link.
// This file is public, so this hides the name from the URL bar, not from view-source.
// Add a broker: pick an unused 2-char code, add it to both maps.
window.BROKERS = {
  byCode:  { "n2": "Jason", "q7": "Matt", "x5": "Tim" },
  byEmail: { "jasoncurcio@tworld.com": "n2", "mnicoletti@tworld.com": "q7", "tcurcio@tworld.com": "x5" }
};
