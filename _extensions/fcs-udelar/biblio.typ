// Intencionalmente vacío: la pauta FCS exige que las Referencias bibliográficas
// aparezcan ANTES de los Anexos, pero el body de Quarto concatena todos los
// capítulos (incluidos los anexos) antes de este partial. Por eso la llamada a
// #bibliography() la escribe bibliography.lua en el lugar del div `#refs` de
// 06-referencias.qmd, y este partial reemplaza al biblio.typ por defecto (que la
// insertaría acá, después de todo el body) para evitar una bibliografía duplicada.
