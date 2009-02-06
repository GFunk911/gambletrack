function updateBetForm(gameID, spread, odds)
{
  document.getElementById("bet_form_"+gameID+"_spread").value = spread
  document.getElementById("bet_form_"+gameID+"_odds").value = odds
}

function clearBetForm(gameID)
{
  document.getElementById("bet_form_"+gameID+"_spread").value = ""
  document.getElementById("bet_form_"+gameID+"_odds").value = ""
  document.getElementById("bet_form_"+gameID+"_amount").value = ""
}