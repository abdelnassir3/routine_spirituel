// Compteur simple pour éviter l'overflow DateTime sur web
int _idCounter = 1000;

String newId() => (++_idCounter).toString();
