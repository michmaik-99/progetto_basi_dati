CALL criticitaTraffico();
CALL inserimentoDoc("SS2629362","2024-02-02","CCCGPP75B42I452Q", "Patente B");
CALL verificaId("SoraLella");
CALL letturaRecensione("SocioAci59");
CALL visioneNoleggiDisponibili(current_date()+ interval 1 day);
CALL visionePoolDisponibili(current_date()+ interval 2 day);
CALL visioneRideDisponibili(current_date()+ interval 2 day);