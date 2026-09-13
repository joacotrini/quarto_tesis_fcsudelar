// Intencionalmente vacío: la pauta FCS exige que las Referencias bibliográficas
// aparezcan ANTES de los Anexos, pero el body de Quarto concatena todos los
// capítulos (incluidos los anexos) antes de este partial. Por eso la llamada a
// #bibliography() se escribe a mano en 06-referencias.qmd, en el lugar correcto,
// y este partial reemplaza al biblio.typ por defecto (que la insertaría acá,
// después de todo el body) para evitar una bibliografía duplicada.
