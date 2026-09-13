#show: doc => conf(
$if(title)$
  title: [$title$],
$endif$
$if(autor)$
  autor: [$autor$],
$endif$
$if(tutor)$
  tutor: [$tutor$],
$endif$
$if(referente-taller2)$
  referente-taller2: [$referente-taller2$],
$endif$
$if(departamento)$
  departamento: [$departamento$],
$endif$
$if(licenciatura)$
  licenciatura: [$licenciatura$],
$endif$
$if(lugar)$
  lugar: [$lugar$],
$endif$
$if(anio)$
  anio: [$anio$],
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(region)$
  region: "$region$",
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$endif$
$if(linestretch)$
  linestretch: $linestretch$,
$endif$
$if(papersize)$
  papersize: "$papersize$",
$endif$
$if(margin)$
  margin: ($for(margin/pairs)$$margin.key$: $margin.value$,$endfor$),
$endif$
$if(section-numbering)$
  section-numbering: "$section-numbering$",
$endif$
  doc,
)
